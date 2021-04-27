infra-init:
	cd infra && terraform init;

infra-format:
	cd infra && terraform fmt;

infra-validate:
	cd infra && terraform validate;

infra-plan: infra-init infra-validate
	cd infra && awsudo -u ${ACCOUNT} terraform plan;

infra-apply: infra-plan
	cd infra && awsudo -u ${ACCOUNT} terraform apply -auto-approve;

infra-destroy:
	cd infra && terraform destroy;