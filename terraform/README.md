# AfroCentric PHI Terraform and API code

## Usage

To deploy this code you will require the following prerequsists:
1. Terraform (Version v1.6.6) installed on your machine
2. Node (v20.11.0) installed on your machine
3. Access into an AWS console to get credentials
4. AWS Role with sufficient permissions to create all of the required resources.
5. Set up your credentials in GitHub
```
Open the Repositor on GitHub
Navigate to "Settings"
On the left panel open "Secrets and variables" -> "Actions"
Click "New repository secret" and add the following (Needs to be done 3 times):
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_SESSION_TOKEN

With each of the above values corresponding to the access keys required to deploy your Lambda code and Lambda layers. Note: AWS_SESSION_TOKEN is only required if you are using a SSO role, if you create a permanent User for this, you will just need the variables for: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY.
```


## Deploying the codebase
To deploy the codebase, do the following:
```bash
# Jump into the terraform folder
cd terraform

# Initialise Terraform
terraform init

# Plan your deployment in Terraform
terraform plan -out=myplan.tfplan

#REVIEW THE PLAN!

# If applicable apply the plan
terraform apply myplan.tfplan
```

Once the terraform has been deployed, you can then trigger off the GitHub actions.

### GitHub actions setup:
You will need to set up 3 environment variables on the github actions found in `.github/worflows/scheduler-depoy-dev`:

1. AWS_DEFAULT_REGION: insert-aws-region-here
2. API_FUNCTION_NAME: insert-name-of-the-API-Lambda-function-here
3. LAMBDA_LAYER_TF_OUTPUT: insert-name-of-the-Lambda-Layers-SSM-Parameter-Store-variable-here

Once you have those above pre-requisits complete, the actions set up will do the following (At a high level) on a push to the relevant branch:
1. Grab the credentials needed to perform AWS manipulation activities from GitHub secrets
2. Checkout the codebase
3. Set up the NodeJS environment
4. Install your dependencies in `package.json`
5. Zip up the dependencies and create a `package` folder
6. Deploy the `package` folder to your specified Lambda function(s)
7. Fetch any Lambda layer ARNs stored in SSM Parameter Store and attach any found layers to your specified Lambda function(s)