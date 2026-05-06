# Makefile for Projet Cloud Terraform — works on Linux/macOS and Windows (with make installed via choco/scoop)

SHELL := /bin/sh

.PHONY: help init plan apply deploy destroy output fmt validate clean

help:           ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-12s\033[0m %s\n",$$1,$$2}'

init:           ## terraform init
	terraform init -upgrade

plan:           ## terraform plan
	terraform plan

apply:          ## terraform apply (auto-approve)
	terraform apply -auto-approve

deploy: init apply output  ## init + apply + show outputs

destroy:        ## terraform destroy (auto-approve)
	TF_VAR_db_password=$${TF_VAR_db_password:-placeholder} terraform destroy -auto-approve

output:         ## Show stack outputs
	terraform output

fmt:            ## Format all .tf files
	terraform fmt -recursive

validate:       ## Validate the configuration
	terraform validate

clean:          ## Remove local Terraform state caches (NOT remote state)
	rm -rf .terraform .terraform.lock.hcl
