# Authentication options

## Configuring SSO

You can configure different SSO backends with `remoteAuth`.
The implementation is based on [Python Social Auth](https://python-social-auth.readthedocs.io/en/latest/backends/index.html#supported-backends).
Depending on the chosen backend you need to configure different parameters.
You can leverage the `extraConfig` value in conjunction with `remoteAuth`.
By default the users do not have any permission after logging in.
Using custom auth pipelines you can assign groups based on the roles supplied by the oauth provider.

## Configuring Keycloak
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

        def set_role(response, user, backend, *args, **kwargs):
            try:
                roles = response['resource_access'][CLIENT_ID]['roles']
            except KeyError:
                roles = []
            user.is_staff = 'admin' in roles
            user.is_superuser = 'superuser' in roles
            user.save()

        def set_groups(response, user, backend, *args, **kwargs):
            django_groups = Group.objects.all()
            sso_groups = response.get('groups', [])
            for group in django_groups:
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