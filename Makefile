AWS_PROFILE ?= auto-repair
REGION      ?= us-east-1
CLUSTER     ?= auto-repair-eks

export AWS_PROFILE

.PHONY: init plan up down kubeconfig outputs

init:
	terraform init -input=false

plan:
	terraform plan -input=false

up:
	terraform apply -input=false -auto-approve

down:
	terraform destroy -input=false -auto-approve

kubeconfig:
	aws eks update-kubeconfig --region $(REGION) --name $(CLUSTER)

outputs:
	terraform output
