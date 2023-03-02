#!/usr/bin/env bash
# This should be part of CI pipeline
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

REPO=https://github.com/wultra/powerauth-tests.git
LOCALDIR="${SCRIPT_DIR}/tmp/powerauth-tests"
git clone "$REPO" "$LOCALDIR" 2> /dev/null || (cd "$LOCALDIR" ; git pull)

mkdir -p "${LOCALDIR}/powerauth-test-server/target"
# Copy built war from remote location (change to wget if package is available in some repo)
rsync -av temp:/root/powerauth-tests/powerauth-test-server/target/powerauth-test-server-1.5.0-SNAPSHOT.war "${LOCALDIR}/powerauth-test-server/target"

IMAGE_NAME=powerauth-test-server
cd "${LOCALDIR}/powerauth-test-server"
docker build . -t ${IMAGE_NAME}
docker image ls | grep ${IMAGE_NAME}

AWS_ACC_ID=$(grep aws_account_id "${SCRIPT_DIR}/terragrunt/non-prod/account.hcl" | awk '{print $3}' | tr -d '"'  )
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin "${AWS_ACC_ID}.dkr.ecr.eu-west-1.amazonaws.com"
docker tag ${IMAGE_NAME}:latest "${AWS_ACC_ID}.dkr.ecr.eu-west-1.amazonaws.com/${IMAGE_NAME}:latest"
docker push "${AWS_ACC_ID}.dkr.ecr.eu-west-1.amazonaws.com/${IMAGE_NAME}:latest"
