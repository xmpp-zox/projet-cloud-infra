#!/usr/bin/env bash
# One-command deploy of the Projet Cloud stack on AWS.
set -euo pipefail
cd "$(dirname "$0")"

echo "==> Checking prerequisites..."
for cmd in terraform aws; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "$cmd is not installed. See README.md."; exit 1; }
done

echo "==> Verifying AWS credentials..."
aws sts get-caller-identity >/dev/null || { echo "AWS credentials missing/expired."; exit 1; }

if [[ -z "${TF_VAR_db_password:-}" ]]; then
  read -r -s -p "Enter a strong RDS master password (min 8 chars): " TF_VAR_db_password
  echo
  export TF_VAR_db_password
  [[ ${#TF_VAR_db_password} -ge 8 ]] || { echo "Password too short."; exit 1; }
fi

[[ -f terraform.tfvars ]] || { cp terraform.tfvars.example terraform.tfvars; \
  echo "Created terraform.tfvars from example — edit if needed, then re-run."; }

echo "==> terraform init"
terraform init -upgrade

echo "==> terraform apply"
terraform apply -auto-approve

echo
echo "==> Stack is up. Outputs:"
terraform output
echo
echo "Frontend builds Angular on first boot (~3-4 min). Then open:"
terraform output -raw frontend_url 2>/dev/null && echo
