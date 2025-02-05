# Obs OTEL Collectors Android

[![Build & deploy](https://github.com/A2B-Australia/obs-otel-dotnet-metrics/actions/workflows/deploy.yml/badge.svg)](https://github.com/A2B-Australia/obs-otel-dotnet-metrics/actions/workflows/deploy.yml)

 - This repo deploys the Azure ContainerApp for Open Telemetry (OTEL) Collector for Android.
  - use Github Actions
  - builds a container from a Dockerfile
  - savers the containewr to Phoenix Azure Container Regsitry (ACR)
  - deploys to the containerApp the Azure COntainer Environment (ACE)





## Phoenix CI/CD for containerApps




### 1) Set secrets & variables in `.env`

1.1) `cp env.example .env`

1.2) Add secrets to `.env`


### 2) Push secrets & variables to Github using bash script

`sh scripts/crud_gh_secrets_and_variables.sh`

### 3) Check  Github Actions runs
- view build & deploy log
- click ton the service URL in the logs to inspect the microservice's end point








