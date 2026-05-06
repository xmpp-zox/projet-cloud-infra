#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
export TF_VAR_db_password="${TF_VAR_db_password:-placeholder-not-used-during-destroy-1234}"
terraform destroy -auto-approve
echo "==> All AWS resources removed."
