# Terraform Easy Cheatsheet

Copy & paste into OneNote. Windows-friendly commands.

## Install & Version
```
choco install terraform   # Windows (Chocolatey)
terraform -version
```

## Azure Auth (common in this repo)
```
az login
az account set --subscription "SUBSCRIPTION_NAME_OR_ID"
```

## Initialize & Validate
```
terraform init                 # download providers & modules
terraform init -upgrade        # update locked provider versions
terraform validate             # check configuration
terraform fmt -recursive       # format files
```

## Plan & Apply
```
terraform plan                 # show changes
terraform plan -out tfplan     # save plan
terraform show tfplan          # view saved plan
terraform apply                # apply interactively
terraform apply tfplan         # apply saved plan
terraform apply -auto-approve  # no prompt (use with care)
```

## Destroy
```
terraform destroy                    # destroy interactively
terraform destroy -auto-approve      # no prompt (careful)
```

## Variables
- Files: `*.tfvars` or `*.auto.tfvars`
- Env: `TF_VAR_name=value`
```
terraform plan -var "env=test" -var-file="environments/test.tfvars"
terraform apply -var-file="environments/test.tfvars"
```

## Outputs
```
terraform output               # show all
terraform output db_conn_str   # show specific
terraform output -json         # machine-readable
```

## Workspaces
```
terraform workspace list
terraform workspace new test
terraform workspace select test
terraform workspace show
terraform workspace delete test
```

## State Operations
```
terraform state list
terraform state show <addr>           # module.resource.id
terraform state mv <src> <dst>        # rename/move in state
terraform state rm <addr>             # remove from state (not destroy)
terraform init -reconfigure           # re-read backend config
terraform init -migrate-state         # move state to new backend
```

## Import Existing Resources
```
# Legacy import (ensure resource exists in .tf)
terraform import <addr> <provider_resource_id>

# Modern: import blocks (Terraform 1.5+)
# Add 'import { to = <addr> id = <id> }' to .tf, then:
terraform plan
terraform apply
```

## Targeting, Replace, Refresh-only
```
terraform plan -target=<addr>            # limit scope (use sparingly)
terraform apply -replace=<addr>          # force recreation
terraform plan -refresh-only              # refresh state only
terraform apply -refresh-only             # update state without changes
```

## Modules & Providers
```
terraform init -upgrade            # update modules/providers
terraform providers                # list used providers
terraform providers schema -json   # provider schema (if supported)
```

## Graph & Console
```
terraform graph | dot -Tpng -o graph.png    # requires Graphviz
terraform console                            # evaluate expressions
```

## Logs & Debug
```
$env:TF_LOG = "INFO"          # DEBUG, TRACE for more
$env:TF_LOG_PATH = "tf.log"   # write logs to file
terraform show -json tfplan    # JSON plan output
```

## Terraform Cloud/Enterprise
```
terraform login                 # set credentials for app.terraform.io
# To switch backends:
terraform init -reconfigure
terraform init -migrate-state
```

## Common File Tips
- Keep provider/version locks in `.terraform.lock.hcl`.
- Use `locals` and `variables` for reusable values.
- Store secrets in Key Vault/Secrets Manager, not plain `.tfvars`.
