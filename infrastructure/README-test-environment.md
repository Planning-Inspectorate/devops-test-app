# Onboarding and Usage: Test Environment for Template Service

## Purpose
These pipelines allow you to spin up and tear down a test environment for the template service using Terraform. This is useful for thorough testing and onboarding new DevOps engineers.

## Files
- Deploy pipeline: `infrastructure/pipelines/terraform-test-deploy.yaml`
- Destroy pipeline: `infrastructure/pipelines/terraform-test-destroy.yaml`
- Environment variables: `infrastructure/environments/test.tfvars`

## How to Use

### 1. Deploy Test Environment
- Run the `terraform-test-deploy.yaml` pipeline in Azure DevOps.
- This will create all resources defined in `infrastructure/main.tf` using variables from `test.tfvars`.

### 2. Destroy Test Environment
- Run the `terraform-test-destroy.yaml` pipeline in Azure DevOps.
- This will destroy all resources created for the test environment.

## Onboarding
- New users can run the deploy pipeline to practice Terraform deployments.
- After testing, run the destroy pipeline to clean up resources.
- Review and update `test.tfvars` as needed for custom test scenarios.

## Notes
- Pipelines do not auto-trigger; run them manually as needed.
- Ensure you have required permissions and service connections set up in Azure DevOps.
- For troubleshooting, check pipeline logs and Terraform output.
