#!/usr/bin/env bash
# This should be part of CI pipeline
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "${SCRIPT_DIR}/terragrunt/non-prod/infra/eu-west-1/infra" && terragrunt apply -auto-approve
