# Authentication options

- [Configuring SSO](#configuring-sso)
- [How group sync works](#how-group-sync-works)
- [Configuring Keycloak (chart-managed)](#configuring-keycloak-chart-managed)
- [Configuring Keycloak (manual via extraConfig)](#configuring-keycloak-manual-via-extraconfig)
- [Configuring Azure AD / Entra ID](#configuring-azure-ad--entra-id)
- [Configuring Google Workspace](#configuring-google-workspace)
- [Configuring Okta](#configuring-okta)
- [Configuring a generic OIDC provider](#configuring-a-generic-oidc-provider)
- [Configuring GitLab](#example-config-for-gitlab-backend)
- [Using LDAP Authentication](#using-ldap-authentication)
- [Troubleshooting](#troubleshooting)

## Configuring SSO

You can configure different SSO backends with `remoteAuth`.
The implementation is based on [Python Social Auth](https://python-social-auth.readthedocs.io/en/latest/backends/index.html#supported-backends).
Depending on the chosen backend you need to configure different parameters.
You can leverage the `extraConfig` value in conjunction with `remoteAuth`.
By default the users do not have any permission after logging in.
Using custom auth pipelines you can assign groups based on the roles supplied by the oauth provider.

## How group sync works

NetBox supports two distinct group-assignment paths. They run *in addition*
to each other — understand both before debugging "user has the wrong groups".

| Key                            | What it does                                                                                                                                                                       |
|--------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `remoteAuth.defaultGroups`     | Static list of group names added to **every** user that authenticates through `remoteAuth`, regardless of provider claims. Applied unconditionally on login by the social-auth pipeline. |
| `remoteAuth.groupSyncEnabled`  | Master switch for *dynamic* group sync. When `true`, the chosen pipeline reads provider-side groups/roles and maps them onto Django Groups.                                       |
| `remoteAuth.groupSeparator`    | Delimiter used to split a single string of groups into a list (default `\|`). Relevant when the provider returns groups via HTTP header (RemoteUserBackend) instead of JSON.       |
| `remoteAuth.groupHeader`       | HTTP header that carries the group list, for RemoteUserBackend setups behind a header-injecting proxy.                                                                              |
| `remoteAuth.superuserGroups`   | Any user whose synced groups include one of these names is promoted to Django `is_superuser=True` on every login.                                                                  |
| `remoteAuth.staffGroups`       | Same idea for `is_staff=True` (admin-site access).                                                                                                                                  |
| `remoteAuth.superusers`        | List of literal usernames to mark as superuser. Bypasses group logic.                                                                                                              |
| `remoteAuth.staffUsers`        | List of literal usernames to mark as staff.                                                                                                                                         |
| `remoteAuth.autoCreateUser`    | If `true`, first-time logins create the Django user; if `false`, the user must exist before SSO works.                                                                              |
| `remoteAuth.autoCreateGroups`  | If `true`, groups named by the provider that don't yet exist in NetBox are created on the fly. Off by default — pre-create groups for tighter control.                              |
| `remoteAuth.defaultPermissions`| Map of permission name → `actions:`/`constraints:`. Applied to `defaultGroups` so anonymous-ish SSO users get *some* read access without one-off configuration.                     |

**Rule of thumb:** `defaultGroups` is for "everyone who logs in gets these
baseline groups." `groupSyncEnabled` + a pipeline function is for "give
this user the groups their IdP says they should have." They compose — a
user can end up in both.

Provider-side, the pipeline needs to know **where** in the OIDC/OAuth
response the groups live. Keycloak puts them under `resource_access`,
`realm_access`, or top-level `groups` depending on which mapper you
configured. Azure puts them in `groups`. Google puts them in
`hd`/`groups` (custom). Okta has a `groups` claim once you add it. The
examples below each spell out the claim path.

## Configuring Keycloak (chart-managed)

The chart ships a `remoteAuth.keycloak.*` convenience block that materializes
the Secret, ConfigMap, and pod mounts needed for a typical Keycloak setup —
you don't need the long `extraConfig` / `extraDeploy` walkthrough below
unless your Keycloak is non-standard. The chart-managed path covers the
common case; the [manual section](#configuring-keycloak-manual-via-extraconfig)
that follows is the fallback for everything else.

### Audience mapper (Keycloak side)

Same Keycloak-side setup as the manual path — required regardless of
which chart approach you pick:

- Clients → `<CLIENT_ID>` → [Tab] Client Scopes → [Tab] Setup → `<CLIENT_ID>-dedicated`
- Mappers → Add mapper → By configuration → Audience
    - Mapper type: Audience
    - Name: `netbox-aud`
    - Included Client Audience: `<CLIENT_ID>`

You also need at least one of these mappers on the same client, matching
your chosen [`groupSource`](#choosing-groupsource):

- "User Client Role" mapper (default — drives `groupSource: client`)
- "User Realm Role" mapper (drives `groupSource: realm`)
- "Group Membership" mapper (drives `groupSource: groups`)

### Minimal values

```yaml
remoteAuth:
  enabled: true
  backends:
    - social_core.backends.keycloak.KeycloakOAuth2
  autoCreateUser: true
  defaultGroups: ['Guests']
  groupSyncEnabled: true
  keycloak:
    enabled: true
    clientId: <KEYCLOAK_CLIENT_ID>
    clientSecret: <KEYCLOAK_CLIENT_SECRET>
    realmUrl: https://keycloak.example.com/realms/<REALM_ID>
    publicKey: |
      MIIB...AB                 # realm RS256 public key body, no BEGIN/END markers
    groupSource: client          # client | realm | groups
    isStaffRole: admin           # Keycloak role → Django is_staff
    isSuperuserRole: superuser   # Keycloak role → Django is_superuser
    extraGroupMappings:
      netops: Network Engineers  # Keycloak-role-name → Django-Group-name (only when they differ)
```

Note: you still list `social_core.backends.keycloak.KeycloakOAuth2` in
`remoteAuth.backends` explicitly — the chart doesn't auto-append it.

### What the chart renders

When `remoteAuth.keycloak.enabled: true`:

| Resource | Contains |
|----------|----------|
| Secret `<release>-remoteauth`, key `oidc-keycloak.yaml` | `SOCIAL_AUTH_KEYCLOAK_KEY`, `_SECRET`, `_PUBLIC_KEY`, `_AUTHORIZATION_URL`, `_ACCESS_TOKEN_URL`, `_SCOPE`, `_PIPELINE`, `SOCIAL_AUTH_JSONFIELD_ENABLED` — rendered from your values |
| ConfigMap `<release>-keycloak-pipeline`, key `keycloak_pipeline_roles.py` | `set_role()` and `set_groups()` functions templated from `isStaffRole`, `isSuperuserRole`, `groupSource`, `extraGroupMappings` |

**Pod mounts** (server pod only — the social-auth pipeline only runs
during a web login, so worker/CronJob skip the mounts):

- The Secret is mounted as a *directory* at `/run/config/extra/remote-auth/`,
  so `oidc-keycloak.yaml` lands as a file at
  `/run/config/extra/remote-auth/oidc-keycloak.yaml`. The chart's
  `configuration.py` walks `/run/config/extra/<provider>/*.yaml` and
  applies each file via `globals().update()` — every key becomes a Django
  setting at process start.
- The pipeline ConfigMap is mounted at
  `/opt/netbox/netbox/netbox/keycloak_pipeline_roles.py`, so the pipeline
  step `netbox.keycloak_pipeline_roles.set_role` (and `.set_groups`)
  resolves as a normal Python import.

### Choosing groupSource

`remoteAuth.keycloak.groupSource` maps to a specific Keycloak client-side
mapper that must exist on the OIDC client. If the mapper is missing, the
claim returns empty and the pipeline silently leaves the user with only
`defaultGroups`.

| `groupSource` | OIDC response field read | Required Keycloak mapper |
|---------------|--------------------------|--------------------------|
| `client` (default) | `response['resource_access'][CLIENT_ID]['roles']` | User Client Role |
| `realm` | `response['realm_access']['roles']` | User Realm Role |
| `groups` | `response['groups']` | Group Membership |

`is_staff` / `is_superuser` are always read from *client* roles regardless
of `groupSource` — Keycloak realm roles and group memberships rarely
carry app-specific privilege markers cleanly enough.

### Overriding the pipeline list

`remoteAuth.keycloak.pipelines` is the full ordered list of social-auth
pipeline steps. To add your own audit / validation step, replace the
whole list (it's not merged with the default):

```yaml
remoteAuth:
  keycloak:
    pipelines:
      - social_core.pipeline.social_auth.social_details
      - social_core.pipeline.social_auth.social_uid
      - social_core.pipeline.social_auth.auth_allowed
      - social_core.pipeline.social_auth.social_user
      - social_core.pipeline.user.get_username
      - social_core.pipeline.social_auth.associate_by_email
      - social_core.pipeline.user.create_user
      - social_core.pipeline.social_auth.associate_user
      - netbox.authentication.user_default_groups_handler
      - social_core.pipeline.social_auth.load_extra_data
      - social_core.pipeline.user.user_details
      - mycompany.audit.log_login           # ← your insertion
      - netbox.keycloak_pipeline_roles.set_role
      - netbox.keycloak_pipeline_roles.set_groups
```

If your custom step lives in a module the netbox image doesn't ship, mount
it via `extraVolumes` / `extraVolumeMounts` alongside the chart-managed
pieces.

### Bringing your own pipeline file

If the chart-generated `set_role` / `set_groups` don't fit your Keycloak
setup (custom claim names, multiple clients, retry logic), supply your
own ConfigMap and point the chart at it:

```yaml
remoteAuth:
  keycloak:
    enabled: true
    existingPipelineConfigMap: my-custom-pipeline-cm
    existingPipelineConfigMapKey: my_pipeline.py   # data-key inside that ConfigMap
```

The chart-rendered `<release>-keycloak-pipeline` ConfigMap is suppressed;
your ConfigMap is mounted at
`/opt/netbox/netbox/netbox/keycloak_pipeline_roles.py` with the subPath
taken from `existingPipelineConfigMapKey`. Your `pipelines:` entries
referring to `netbox.keycloak_pipeline_roles.<func>` then resolve to
*your* implementation.

### When to use the manual recipe instead

The chart-managed path assumes you want one Keycloak client mapped onto
one set of Django groups. Drop down to the
[manual recipe below](#configuring-keycloak-manual-via-extraconfig) when:

- You have multiple Keycloak clients (different realms or audiences)
  authenticating one netbox.
- You need to merge values with another `extraConfig` chain that's not
  Keycloak-related (the chart-managed path is additive — coexisting
  configurations work fine — but if your existing setup is already on the
  manual path, migrating piecemeal is awkward).
- You need to react to the Keycloak response at pipeline time in ways the
  chart-generated functions don't cover (custom claim parsing, side
  effects to external systems, fine-grained group → permission mapping).

## Configuring Keycloak (manual via extraConfig)

Use this approach when the chart-managed `remoteAuth.keycloak.*` block
doesn't fit, or as a reference for what the chart does under the hood.

Add Audience mapper

- Clients -> <CLIENT_ID> -> [Tab] Client Scopes -> [Tab] Setup -> <CLIENT_ID>-dedicated
- Mappers -> Add mapper -> By configuration -> Audience
    - Mapper type: Audience
    - Name: netbox-aud
    - Included Client Audience: <CLIENT_ID>

### Example config for Keycloak backend

```yaml
remoteAuth:
  enabled: true
  backends:
    - social_core.backends.keycloak.KeycloakOAuth2
  autoCreateUser: true
  defaultGroups: ['Guests']
  groupSyncEnabled: true
  groupSeparator: ','

extraConfig:
  - secret:
      secretName: keycloak-client
  - values:
      SOCIAL_AUTH_KEYCLOAK_PIPELINE:
        [
          "social_core.pipeline.social_auth.social_details",
          "social_core.pipeline.social_auth.social_uid",
          "social_core.pipeline.social_auth.auth_allowed",
          "social_core.pipeline.social_auth.social_user",
          "social_core.pipeline.user.get_username",
          "social_core.pipeline.social_auth.associate_by_email",
          "social_core.pipeline.user.create_user",
          "social_core.pipeline.social_auth.associate_user",
          "netbox.authentication.user_default_groups_handler",
          "social_core.pipeline.social_auth.load_extra_data",
          "social_core.pipeline.user.user_details",
          "netbox.keycloak_pipeline_roles.set_role",
          "netbox.keycloak_pipeline_roles.set_groups",
        ]

extraVolumes:
  - name: keycloak-pipeline-roles
    configMap:
      name: keycloak-pipeline-roles

extraVolumeMounts:
  - name: keycloak-pipeline-roles
    mountPath: /opt/netbox/netbox/netbox/keycloak_pipeline_roles.py
    subPath: keycloak_pipeline_roles.py
    readOnly: true
```

Put additional necessary resources on `extraDeploy` parameter.
Note: Client ID is necessary in the custom pipeline script

```yaml
extraDeploy:
  - apiVersion: v1
    kind: Secret
    metadata:
      name: keycloak-client
      namespace: netbox
    type: Opaque
    stringData:
      oidc-keycloak.yaml: |
        SOCIAL_AUTH_KEYCLOAK_KEY:               <KEYCLOAK_CLIENT_ID>
        SOCIAL_AUTH_KEYCLOAK_SECRET:            <KEYCLOAK_CLIENT_SECRET>
        SOCIAL_AUTH_KEYCLOAK_PUBLIC_KEY:        MIIB...AB
        SOCIAL_AUTH_KEYCLOAK_AUTHORIZATION_URL: "https://keycloak.example.com/realms/<REALM_ID>/protocol/openid-connect/auth"
        SOCIAL_AUTH_KEYCLOAK_ACCESS_TOKEN_URL:  "https://keycloak.example.com/realms/<REALM_ID>/protocol/openid-connect/token"
        SOCIAL_AUTH_JSONFIELD_ENABLED:          true

  - apiVersion: v1
    kind: ConfigMap
    metadata:
      name: keycloak-pipeline-roles
      namespace: netbox
    data:
      keycloak_pipeline_roles.py: |
        from django.contrib.auth.models import Group

        # this must match your actual keycloak client ID string!
        CLIENT_ID = "<KEYCLOAK_CLIENT_ID>"

        # Source for Django group mapping:
        #   "client" -> response['resource_access'][CLIENT_ID]['roles']
        #               (requires a "User Client Role" mapper on the client)
        #   "realm"  -> response['realm_access']['roles']
        #               (requires a "User Realm Role" mapper on the client)
        #   "groups" -> response['groups']
        #               (requires a "Group Membership" mapper on the client)
        GROUP_SOURCE = "client"

        def _client_roles(response):
            try:
                return response['resource_access'][CLIENT_ID]['roles']
            except KeyError:
                return []

        def _realm_roles(response):
            try:
                return response['realm_access']['roles']
            except KeyError:
                return []

        def set_role(response, user, backend, *args, **kwargs):
            roles = _client_roles(response)
            user.is_staff = 'admin' in roles
            user.is_superuser = 'superuser' in roles
            user.save()

        def set_groups(response, user, backend, *args, **kwargs):
            if GROUP_SOURCE == "client":
                sso_groups = _client_roles(response)
            elif GROUP_SOURCE == "realm":
                sso_groups = _realm_roles(response)
            else:
                sso_groups = response.get('groups', [])
            for group in Group.objects.all():
                try:
                    if group.name in sso_groups:
                        group.user_set.add(user)
                    else:
                        group.user_set.remove(user)
                except Group.DoesNotExist:
                    continue
```

Ref:

- https://github.com/netbox-community/netbox/discussions/8579

## Configuring Azure AD / Entra ID

`python-social-auth` ships an Azure AD OAuth2 backend
(`social_core.backends.azuread.AzureADOAuth2`). For multi-tenant or
single-tenant Entra ID apps, prefer the tenant-scoped variant
(`AzureADV2TenantOAuth2`) which uses the v2 endpoint and emits a `groups`
claim out of the box once you toggle "Group ID claim" in the app's *Token
configuration* blade.

Required app-registration steps in Azure portal:

1. **App registrations → New registration** — set the redirect URI to
   `https://<netbox-host>/oauth/complete/azuread-v2-tenant/`.
2. **Certificates & secrets → New client secret** — copy the *Value*
   (not the ID).
3. **Token configuration → Add groups claim** — pick `Security groups`
   (or `Groups assigned to the application`) for both ID token and
   access token. Format: **Group ID**.
4. **API permissions** — add `openid`, `profile`, `email`, and
   `User.Read`. Grant admin consent.

```yaml
remoteAuth:
  enabled: true
  backends:
    - social_core.backends.azuread_tenant.AzureADV2TenantOAuth2
  autoCreateUser: true
  defaultGroups: ['Guests']
  groupSyncEnabled: true

extraConfig:
  - secret:
      secretName: azuread-client
  - values:
      SOCIAL_AUTH_AZUREAD_V2_TENANT_OAUTH2_PIPELINE:
        [
          "social_core.pipeline.social_auth.social_details",
          "social_core.pipeline.social_auth.social_uid",
          "social_core.pipeline.social_auth.auth_allowed",
          "social_core.pipeline.social_auth.social_user",
          "social_core.pipeline.user.get_username",
          "social_core.pipeline.social_auth.associate_by_email",
          "social_core.pipeline.user.create_user",
          "social_core.pipeline.social_auth.associate_user",
          "netbox.authentication.user_default_groups_handler",
          "social_core.pipeline.social_auth.load_extra_data",
          "social_core.pipeline.user.user_details",
          "netbox.azuread_pipeline_roles.set_groups",
        ]

extraDeploy:
  - apiVersion: v1
    kind: Secret
    metadata:
      name: azuread-client
      namespace: netbox
    type: Opaque
    stringData:
      oidc-azuread.yaml: |
        SOCIAL_AUTH_AZUREAD_V2_TENANT_OAUTH2_KEY:    <APP_CLIENT_ID>
        SOCIAL_AUTH_AZUREAD_V2_TENANT_OAUTH2_SECRET: <CLIENT_SECRET_VALUE>
        SOCIAL_AUTH_AZUREAD_V2_TENANT_OAUTH2_TENANT_ID: <TENANT_GUID>
        SOCIAL_AUTH_AZUREAD_V2_TENANT_OAUTH2_RESOURCE: "https://graph.microsoft.com/"

  - apiVersion: v1
    kind: ConfigMap
    metadata:
      name: azuread-pipeline-roles
      namespace: netbox
    data:
      azuread_pipeline_roles.py: |
        from django.contrib.auth.models import Group

        # Entra ID emits group object IDs (GUIDs) in the 'groups' claim. Map
        # those GUIDs to the NetBox-side Group names you want them to drive.
        GROUP_MAP = {
            "11111111-2222-3333-4444-555555555555": "NetBox Admins",
            "66666666-7777-8888-9999-aaaaaaaaaaaa": "NetBox Operators",
        }

        def set_groups(response, user, backend, *args, **kwargs):
            azure_groups = response.get('groups', []) or []
            wanted = {GROUP_MAP[g] for g in azure_groups if g in GROUP_MAP}
            for group in Group.objects.all():
                if group.name in wanted:
                    group.user_set.add(user)
                else:
                    group.user_set.remove(user)
            user.is_staff = "NetBox Admins" in wanted
            user.is_superuser = "NetBox Admins" in wanted
            user.save()

extraVolumes:
  - name: azuread-pipeline-roles
    configMap:
      name: azuread-pipeline-roles

extraVolumeMounts:
  - name: azuread-pipeline-roles
    mountPath: /opt/netbox/netbox/netbox/azuread_pipeline_roles.py
    subPath: azuread_pipeline_roles.py
    readOnly: true
```

If you'd rather work in **group names** than GUIDs, switch the Token
configuration claim to *Cloud-only group display names* — but be aware
that on-prem-synced groups stay as GUIDs even with that toggle, so a mixed
directory will give you a mix of GUIDs and names in the claim.

## Configuring Google Workspace

`social_core.backends.google.GoogleOAuth2` covers consumer Google accounts;
for Workspace ("hosted domain") use the same backend with
`SOCIAL_AUTH_GOOGLE_OAUTH2_WHITELISTED_DOMAINS` pinned to your tenant.

Google does **not** expose org-units or groups via the standard OIDC
endpoint — you'll need to enrich the response with a directory lookup
(Admin SDK / `directory.groups.list`). The example below shows the
minimal "everyone in `example.com` becomes Guests" setup; for group sync
add a pipeline function similar to the Azure example that calls the
Admin SDK with a service account.

```yaml
remoteAuth:
  enabled: true
  backends:
    - social_core.backends.google.GoogleOAuth2
  autoCreateUser: true
  defaultGroups: ['Guests']

extraConfig:
  - secret:
      secretName: google-client
  - values:
      SOCIAL_AUTH_GOOGLE_OAUTH2_WHITELISTED_DOMAINS:
        - example.com

extraDeploy:
  - apiVersion: v1
    kind: Secret
    metadata:
      name: google-client
      namespace: netbox
    type: Opaque
    stringData:
      oidc-google.yaml: |
        SOCIAL_AUTH_GOOGLE_OAUTH2_KEY:    <OAUTH_CLIENT_ID>.apps.googleusercontent.com
        SOCIAL_AUTH_GOOGLE_OAUTH2_SECRET: <OAUTH_CLIENT_SECRET>
```

Redirect URI in the Google Cloud Console OAuth client must be
`https://<netbox-host>/oauth/complete/google-oauth2/`.

## Configuring Okta

Use `social_core.backends.okta_openidconnect.OktaOpenIdConnect`. Okta
exposes a `groups` claim once you add a *Groups Claim Filter* on the
authorization server (default: filter `name` matches `.*` to ship all
groups).

```yaml
remoteAuth:
  enabled: true
  backends:
    - social_core.backends.okta_openidconnect.OktaOpenIdConnect
  autoCreateUser: true
  defaultGroups: ['Guests']
  groupSyncEnabled: true

extraConfig:
  - secret:
      secretName: okta-client
  - values:
      SOCIAL_AUTH_OKTA_OPENIDCONNECT_PIPELINE:
        [
          "social_core.pipeline.social_auth.social_details",
          "social_core.pipeline.social_auth.social_uid",
          "social_core.pipeline.social_auth.auth_allowed",
          "social_core.pipeline.social_auth.social_user",
          "social_core.pipeline.user.get_username",
          "social_core.pipeline.social_auth.associate_by_email",
          "social_core.pipeline.user.create_user",
          "social_core.pipeline.social_auth.associate_user",
          "netbox.authentication.user_default_groups_handler",
          "social_core.pipeline.social_auth.load_extra_data",
          "social_core.pipeline.user.user_details",
          "netbox.okta_pipeline_roles.set_groups",
        ]

extraDeploy:
  - apiVersion: v1
    kind: Secret
    metadata:
      name: okta-client
      namespace: netbox
    type: Opaque
    stringData:
      oidc-okta.yaml: |
        SOCIAL_AUTH_OKTA_OPENIDCONNECT_KEY:    <OKTA_CLIENT_ID>
        SOCIAL_AUTH_OKTA_OPENIDCONNECT_SECRET: <OKTA_CLIENT_SECRET>
        SOCIAL_AUTH_OKTA_OPENIDCONNECT_API_URL: https://<your-okta-org>.okta.com/oauth2/default

  - apiVersion: v1
    kind: ConfigMap
    metadata:
      name: okta-pipeline-roles
      namespace: netbox
    data:
      okta_pipeline_roles.py: |
        from django.contrib.auth.models import Group

        def set_groups(response, user, backend, *args, **kwargs):
            okta_groups = set(response.get('groups', []) or [])
            for group in Group.objects.all():
                if group.name in okta_groups:
                    group.user_set.add(user)
                else:
                    group.user_set.remove(user)
            user.is_staff = "netbox-admins" in okta_groups
            user.is_superuser = "netbox-admins" in okta_groups
            user.save()

extraVolumes:
  - name: okta-pipeline-roles
    configMap:
      name: okta-pipeline-roles

extraVolumeMounts:
  - name: okta-pipeline-roles
    mountPath: /opt/netbox/netbox/netbox/okta_pipeline_roles.py
    subPath: okta_pipeline_roles.py
    readOnly: true
```

Redirect URI in the Okta app: `https://<netbox-host>/oauth/complete/okta-openidconnect/`.

## Configuring a generic OIDC provider

For any other OIDC-compliant provider use `social_core.backends.open_id_connect.OpenIdConnectAuth`.
You'll need the OIDC discovery URL (the `.well-known/openid-configuration`
endpoint) — the backend pulls JWKS and endpoints from there.

```yaml
remoteAuth:
  enabled: true
  backends:
    - social_core.backends.open_id_connect.OpenIdConnectAuth
  autoCreateUser: true
  defaultGroups: ['Guests']

extraConfig:
  - secret:
      secretName: oidc-client
  - values:
      SOCIAL_AUTH_OIDC_OIDC_ENDPOINT: https://idp.example.com/realms/myrealm
      # Map a non-standard claim to the Django username field:
      SOCIAL_AUTH_OIDC_USERNAME_KEY: preferred_username

extraDeploy:
  - apiVersion: v1
    kind: Secret
    metadata:
      name: oidc-client
      namespace: netbox
    type: Opaque
    stringData:
      oidc-generic.yaml: |
        SOCIAL_AUTH_OIDC_KEY:    <CLIENT_ID>
        SOCIAL_AUTH_OIDC_SECRET: <CLIENT_SECRET>
```

Redirect URI: `https://<netbox-host>/oauth/complete/oidc/`.

### Example config for GitLab backend
```yaml
remoteAuth:
  enabled: true
  backends:
    - social_core.backends.gitlab.GitLabOAuth2
  autoCreateUser: true

extraConfig:
  - secret:
      secretName: gitlab-client
  - values:
      SOCIAL_AUTH_GITLAB_PIPELINE:
        [
            "social_core.pipeline.social_auth.social_details",
            "social_core.pipeline.social_auth.social_uid",
            "social_core.pipeline.social_auth.social_user",
            "social_core.pipeline.user.get_username",
            "social_core.pipeline.social_auth.associate_by_email",
            "social_core.pipeline.user.create_user",
            "social_core.pipeline.social_auth.associate_user",
            "netbox.authentication.user_default_groups_handler",
            "social_core.pipeline.social_auth.load_extra_data",
            "social_core.pipeline.user.user_details",
            "netbox.gitlab_pipeline_roles.set_role",
        ]

extraVolumes:
  - name: gitlab-pipeline-roles
    configMap:
      name: gitlab-pipeline-roles

extraVolumeMounts:
  - name: gitlab-pipeline-roles
    mountPath: /opt/netbox/netbox/netbox/gitlab_pipeline_roles.py
    subPath: gitlab_pipeline_roles.py
    readOnly: true
```

Additional resources are necessary (please note that the client ID is necessary in the custom pipeline script):

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-client
  namespace: netbox
type: Opaque
stringData:
  oidc-gitlab.yaml: |
    SOCIAL_AUTH_GITLAB_API_URL: https://git.example.com
    SOCIAL_AUTH_GITLAB_AUTHORIZATION_URL: https://git.example.com/oauth/authorize
    SOCIAL_AUTH_GITLAB_ACCESS_TOKEN_URL: https://git.example.com/oauth/token
    SOCIAL_AUTH_GITLAB_KEY: <OAUTH_CLIENT_ID>
    SOCIAL_AUTH_GITLAB_SECRET: <OAUTH_CLIENT_SECRET>
    SOCIAL_AUTH_GITLAB_SCOPE: ['read_user', 'openid']

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: gitlab-pipeline-roles
  namespace: netbox
data:
  gitlab_pipeline_roles.py: |
    from django.contrib.auth.models import Group
    import jwt
    from jwt import PyJWKClient
    def set_role(response, user, backend, *args, **kwargs):
      jwks_client = PyJWKClient("https://git.example.com/oauth/discovery/keys")
      signing_key = jwks_client.get_signing_key_from_jwt(response['id_token'])
      decoded = jwt.decode(
          response['id_token'],
          signing_key.key,
          algorithms=["RS256"],
          audience="<OAUTH_CLIENT_ID>",
      )
      roles = []
      try:
        roles = decoded.get('groups_direct')
      except KeyError:
        pass
      user.is_staff = ('network' in roles)
      user.is_superuser = ('network' in roles)
      user.save()
      groups = Group.objects.all()
      for group in groups:
        try:
          if group.name in roles:
            group.user_set.add(user)
          else:
            group.user_set.remove(user)
        except Group.DoesNotExist:
          continue
```

## Using LDAP Authentication

In order to enable LDAP authentication, please carry out the following steps:

1. Set `image.tag` in your values to an image with LDAP support (e.g. `v3.0.11-ldap`)
2. Configure the `remoteAuth` settings to enable the LDAP backend (see below)
3. Make sure you set *all* of the `remoteAuth.ldap` settings shown in the `values.yaml` file

For example:

```yaml
remoteAuth:
  enabled: true
  backends:
    - netbox.authentication.LDAPBackend
  ldap:
    enabled: true
    serverUri: 'ldap://domain.com'
    startTls: true
    ignoreCertErrors: true
    bindDn: ''
    bindPassword: ''
    # and ALL the other remoteAuth.ldap.* settings from values.yaml
```

Note: in order to use anonymous LDAP binding set `bindDn` and `bindPassword`
to an empty string as in the example above.

## Troubleshooting

### "User logs in but lands on a 403 / has no permissions"

The most common cause is that no pipeline step assigned the user to any
NetBox Group. Check, in order:

1. `remoteAuth.defaultGroups` is set to at least one group that *exists*
   in NetBox. If the group is misspelled or hasn't been pre-created,
   `user_default_groups_handler` silently no-ops.
2. The custom pipeline function (e.g. `set_groups`) is listed in
   the backend-specific `*_PIPELINE` *after* `create_user` —
   otherwise the user object doesn't yet have a primary key when your
   function tries to add it to a group.
3. The provider response actually contains the claim you're reading.
   Tail the netbox container while signing in:
   ```bash
   kubectl logs -f deploy/netbox -c netbox | grep -i social
   ```
   then add a `print(response)` line at the top of your `set_groups`
   function and bounce the pod. If `response.get('groups')` is `None`,
   the IdP-side mapper isn't shipping the claim — fix the provider, not
   NetBox.

### "Groups not syncing even though they appear in the token"

- **Keycloak**: the `GROUP_SOURCE` constant in the pipeline file must
  match the mapper type on the client. `client` requires a *User Client
  Role* mapper, `realm` requires a *User Realm Role* mapper, `groups`
  requires a *Group Membership* mapper. Check via the realm admin →
  Clients → `<your-client>` → Client scopes → `…-dedicated` → Mappers.
- **Azure AD**: the `groups` claim ships GUIDs, not names. Either map
  GUIDs in the pipeline (see [Configuring Azure AD / Entra ID](#configuring-azure-ad--entra-id))
  or switch the Token configuration claim to *Cloud-only group display
  names* — but on-prem-synced groups stay as GUIDs in mixed directories.
- **Okta**: if the Groups Claim Filter is set to `Starts with` or
  similar, only matching groups are emitted. Set it to `Matches regex
  .*` while debugging.

### "redirect_uri mismatch"

The redirect URI registered with the IdP must end in the trailing slash
the social-auth backend uses. The Bitnami values footer enforces it.
Quick reference:

| Backend                  | Path                                                  |
|--------------------------|-------------------------------------------------------|
| `KeycloakOAuth2`         | `/oauth/complete/keycloak/`                            |
| `AzureADV2TenantOAuth2`  | `/oauth/complete/azuread-v2-tenant/`                   |
| `GoogleOAuth2`           | `/oauth/complete/google-oauth2/`                       |
| `OktaOpenIdConnect`      | `/oauth/complete/okta-openidconnect/`                  |
| `OpenIdConnectAuth`      | `/oauth/complete/oidc/`                                |
| `GitLabOAuth2`           | `/oauth/complete/gitlab/`                              |

If your NetBox is served behind a path prefix (`basePath`), the prefix
is included in the URI — verify against `httpRelativePath` /
`basePath` in your values.

### "Token expired" loops

`python-social-auth` doesn't refresh tokens by default. If your IdP's
access token TTL is short and you see users bounced back to the IdP
mid-session, add the refresh step to the pipeline:

```yaml
SOCIAL_AUTH_<BACKEND>_PIPELINE:
  - ...
  - social_core.pipeline.social_auth.load_extra_data
  - social_core.pipeline.user.user_details
  - social_core.pipeline.social_auth.refresh_token
```

Note that `social_core.pipeline.social_auth.refresh_token` is **not**
part of the default pipeline — you need to add it explicitly per backend.

### "LDAP bind succeeds but no users sync"

When `remoteAuth.ldap.enabled: true` the chart writes
`ldap_bind_password` into the projected `secrets` volume — make sure
your `ldap_config.py` references it via
`/run/secrets/netbox/ldap_bind_password`, not by setting `bindPassword`
in plaintext. Older chart versions wrote the bind password to the wrong
secret key; if you upgraded from a chart older than 5.1.1, rotate the
bind password and re-apply.
