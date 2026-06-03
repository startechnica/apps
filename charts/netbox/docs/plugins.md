# Installing NetBox plugins

Setting `plugins:` in `values.yaml` is **not enough on its own** — it only
populates Django's `PLUGINS` / `PLUGINS_CONFIG` settings. The plugin's
Python package still has to be importable inside the container, and the
upstream `netboxcommunity/netbox` image only ships the base NetBox
distribution. To make `import <your_plugin>` succeed at process start,
build a derived image that overlays `pip install` on top of the upstream
one and point the chart's three `image:` blocks at it.

Tracks [#62](https://github.com/startechnica/apps/issues/62).

## 1. Build a derived image

`netboxcommunity/netbox` reads `/opt/netbox/local_requirements.txt` at
build time and `pip install -r`s it into the bundled venv. The simplest
overlay appends your plugins to that file and pip-installs them:

```dockerfile
# Pin the same tag your chart points at — keep image, chart, and plugin
# in version-lockstep so an unrelated NetBox bump can't break a plugin.
FROM netboxcommunity/netbox:v3.7.8-2.8.0

USER root
RUN echo "netbox_qrcode==0.0.13"     >> /opt/netbox/local_requirements.txt \
 && echo "netbox-inventory==1.4.1"   >> /opt/netbox/local_requirements.txt
RUN . /opt/netbox/venv/bin/activate \
 && pip install -r /opt/netbox/local_requirements.txt
USER 1000

# (optional) drop migrations into place so they run on next housekeeping pass
# COPY --chown=1000:1000 ./netbox-inventory-migrations /opt/netbox/netbox/...
```

Build, tag, and push to a registry the cluster can pull from:

```bash
docker build -t registry.example.com/ops/netbox:v3.7.8-2.8.0-plugins .
docker push registry.example.com/ops/netbox:v3.7.8-2.8.0-plugins
```

**Pin plugin versions.** `netbox-inventory` without a version pin lets a
new release land in a future rebuild and break migrations or admin
templates silently.

## 2. Point the chart at the derived image

After the 5.1.0 changes ([#83](https://github.com/startechnica/apps/issues/83) /
[#64](https://github.com/startechnica/apps/issues/64)), each of
`image:`, `worker.image:`, and `housekeeping.image:` carries its own
registry/repository/tag. Override all three so the server, RQ workers,
and housekeeping CronJob all import your plugin code:

```yaml
image:
  registry: registry.example.com
  repository: ops/netbox
  tag: v3.7.8-2.8.0-plugins

worker:
  image:
    registry: registry.example.com
    repository: ops/netbox
    tag: v3.7.8-2.8.0-plugins

housekeeping:
  image:
    registry: registry.example.com
    repository: ops/netbox
    tag: v3.7.8-2.8.0-plugins
```

Or, if you don't need per-component divergence, set the top-level
`global.image*` block once — it's the fall-through value when the
per-component block is empty:

```yaml
global:
  imageRegistry: registry.example.com
  imageRepository: ops/netbox
  imageTag: v3.7.8-2.8.0-plugins
```

If your registry requires auth, add the pull secret via the standard
chart knob:

```yaml
global:
  imagePullSecrets:
    - my-registry-credentials
```

## 3. Enable the plugin in `values.yaml`

Once the package is importable, the chart-side wiring kicks in. Set
`plugins:` to the dotted-module names you want NetBox to load and
`pluginsConfig:` to whatever per-plugin config the plugin's README
documents:

```yaml
plugins:
  - netbox_qrcode
  - netbox_inventory

pluginsConfig:
  netbox_qrcode:
    title: netbox_qrcode
    url_field: serial
  netbox_inventory:
    top_level_menu: true
```

The chart renders these into `configuration.py` as `PLUGINS` and
`PLUGINS_CONFIG` Django settings.

## 4. Migrate on first boot

Most plugins ship database migrations. The chart's housekeeping CronJob
runs `manage.py housekeeping` which already runs migrations as part of
its loop, but on a brand-new release you usually want migrations applied
*before* the web pods start accepting traffic. Two options:

1. **Wait for housekeeping.** The next scheduled CronJob run (default
   daily) applies migrations. Acceptable for low-traffic releases.
2. **Run a one-shot Job.** Add a custom `extraDeploy` entry that runs
   `manage.py migrate` once on upgrade:

   ```yaml
   extraDeploy:
     - apiVersion: batch/v1
       kind: Job
       metadata:
         name: '{{ include "st-common.names.fullname" . }}-migrate'
         annotations:
           "helm.sh/hook": post-install,post-upgrade
           "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
       spec:
         template:
           spec:
             restartPolicy: OnFailure
             containers:
               - name: migrate
                 image: registry.example.com/ops/netbox:v3.7.8-2.8.0-plugins
                 command:
                   - /opt/netbox/venv/bin/python
                   - /opt/netbox/netbox/manage.py
                   - migrate
                 envFrom:
                   - secretRef:
                       name: '{{ include "st-common.names.fullname" . }}'
                 volumeMounts:
                   - name: config
                     mountPath: /etc/netbox/config/configuration.py
                     subPath: configuration.py
                     readOnly: true
             volumes:
               - name: config
                 configMap:
                   name: '{{ include "st-common.names.fullname" . }}'
   ```

## 5. Static files

Plugins that ship static assets (CSS, JS, images) need `collectstatic`
to be re-run so the Unit-served `/static/` mount picks them up. The
upstream entrypoint script handles this automatically on container start,
provided `SKIP_STARTUP_SCRIPTS` is unset (default). No extra wiring
required unless you explicitly disabled startup scripts.

## Troubleshooting

### Pod CrashLoopBackOff with `ModuleNotFoundError: No module named '<plugin>'`

The plugin name in `plugins:` doesn't match the **importable Python
module** — `pip install foo-bar` often produces `import foo_bar`. Run
`pip show <package>` inside the derived image and grep the `Files:` list
for the actual top-level module name.

### Plugin works on server pods but worker shows the same `ModuleNotFoundError`

You forgot to point `worker.image.*` at the derived image. The server,
worker, and housekeeping pods are three separate `image:` blocks since
5.1.0 — set all three (or use `global.image*` so they share fall-through).

### Plugin needs an environment variable

Two options:

- Per-plugin config in `pluginsConfig:` if the plugin reads it from
  Django settings.
- `extraEnvVars:` on the server (and `worker.extraEnvVars`,
  `housekeeping.extraEnvVars` if the plugin runs background jobs):

  ```yaml
  extraEnvVars:
    - name: NETBOX_QRCODE_DEBUG
      value: "1"
  ```

### "Migrations seem to apply but the admin page 500s"

Plugin's admin templates conflict with another plugin or with NetBox
core. Check `manage.py runserver` logs locally with just the plugin
installed before deploying. Most plugin authors document NetBox
version-compat ranges — pinning to a tested combination usually fixes it.

## See also

- [docs/auth.md](auth.md) — SSO / LDAP setup
- [README §Upgrading](../README.md#upgrading) — per-version migration notes
- Upstream plugin docs at <https://docs.netbox.dev/en/stable/plugins/>
