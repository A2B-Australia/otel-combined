# OBS-OTEL

This is a monorepo - a repo combining multiple sub-repositories as git modules.

### Child Repositories

|#|Repo Name|Pupose|Repo URL|
|--|--|--|--|
|1|obs-otel-terraform-infra|Terraform code|[A2B-Australia/obs-otel-terraform-infra](https://github.com/A2B-Australia/obs-otel-terraform-infra)|
|2|obs-otel-collector-infra|OTEL Collector for all Infrastructure|[A2B-Australia/obs-otel-collector-infra](https://github.com/A2B-Australia/obs-otel-collector-infra)|
|3|obs-otel-collector-android| OTEL Collector for Android||
||||
|4|obs-otel-dotnet-logs| OTEL Collector for Logs||
|5|obs-otel-dotnet-metrics| OTEL Collector for Metrics||
|6|obs-otel-dotnet-traces| OTEL Collector for Traces||
|7|obs-otel-jaeger| Jaegar Dashboard for displaying traces|[A2B-Australia/obs-otel-jaegar](https://github.com/A2B-Australia/obs-otel-jaegar)|
|8|obs-otel-prometheus| Prometheus if required...??||

---
### Other Directories Explained

**Scripts**

Various `az cli` helper scripts

---
### Adding git submodules
```
git submodule add https://github.com/A2B-Australia/obs-otel-terraform obs-otel-terraform
git submodule add https://github.com/A2B-Australia/obs-otel-jaegar obs-otel-jaegar
git submodule add https://github.com/A2B-Australia/obs-otel-collector-infra obs-otel-collector-infra

git submodule add https://github.com/A2B-Australia/obs-otel-dotnet-logs obs-otel-dotnet-logs
git submodule add https://github.com/A2B-Australia/obs-otel-dotnet-traces obs-otel-dotnet-traces
git submodule add https://github.com/A2B-Australia/obs-otel-dotnet-metrics obs-otel-dotnet-metrics
git submodule add https://github.com/A2B-Australia/obs-otel-collector-android obs-otel-collector-android

git submodule add https://github.com/ianscrivener-a2b/obs-otel-seq obs-otel-seq
git submodule add https://github.com/A2B-Australia/obs-otel-terraform A2B-Australia/obs-otel-terraform

```
