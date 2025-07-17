# Changelog

## 0.1.13 (2025-07-17)

* fix: gateway namespace st-common.gateway.namespace ([ae63ced](https://github.com/startechnica/apps/commit/ae63ced5a8dcf3b9da297d3329d722e541b52a6c))
* add: gateway cluster domain st-common.gateway.clusterDomain ([ae63ced](https://github.com/startechnica/apps/commit/ae63ced5a8dcf3b9da297d3329d722e541b52a6c))
* fix: st-common.capabilities.vpa.apiVersion ([dd59156](https://github.com/startechnica/apps/commit/dd59156337250ca9b89017197a8d90a26833eedc))
* fix: Prevent release name from breaking DNS naming specification ([dd59156](https://github.com/startechnica/apps/commit/dd59156337250ca9b89017197a8d90a26833eedc))
* add: namespaces to extraPodAffinityTerms for affinities

## 0.1.12 (2025-04-13)

* Move capabilities helper to its own dir
* Add st-common.bac.serviceAccountName for ServiceAccount name
* Add st-common.utils.stringOrNumber
* Add dotenv and envvars names helper


## 0.1.11 (2025-03-24)

* Add more Cloudnative PG apiVersion
* Add new MongoDB Community Operator apiversion
* Add OpenEBS Local-LVM apiversion
* Add helper to check API versions
* Add validations helpers