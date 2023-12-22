#!/bin/bash
export GITHUB_USER=kriipke
export GITHUB_REPO=flux2-multi-tenancy
flux check --pre && flux bootstrap github \
    --context=do-nyc1-management \
    --owner=${GITHUB_USER} \
    --repository=${GITHUB_REPO} \
    --branch=main \
    --personal \
    --path=clusters/staging
