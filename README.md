# Infrastructure for powerauth-test-server on AWS
App source: https://github.com/wultra/powerauth-tests/tree/develop/powerauth-test-server
## Requirements
- prebuilt app.war file in registry
- Terraform v1.3.9
- Terragrunt v0.44.0
- AWS Account with VPC, Subnets and InternetGateway available
- AWS Credentials with enough permissions (TBD)
- bash
## Deployment
__Terragrunt automatically creates s3 buckets for terraform state files__
Steps:
  - update variables in [common_vars.hcl](terragrunt%2Fcommon_vars.hcl), account.hcl[account.hcl](terragrunt%2Fnon-prod%2Faccount.hcl) and  both region.hcl (app+infra) to match your AWS environment
  - deploy infra requirements with [deploy_infra.sh](deploy_infra.sh)
  - build and deploy docker image using [build_and_push_docker.sh](build_and_push_docker.sh)
  - deploy application: `cd terragrunt/non-prod && terragrunt run-all apply`

## Future improvements
- Move terraform/modules to separate repos to get advantage of sharing and versioning
- Make everything encrypted (ECR, RDS, HTTPS....)
- Store DB credentials in secrets manager
- Create CI/CD pipelines which could have steps:
  - CI: 
    - Build and Push war + docker packages to respective registries
    - deploy latest docker tag to ECS (via terraform)
  - create release packages
  - CD
    - deploy release tag to ECS (via terraform)
    