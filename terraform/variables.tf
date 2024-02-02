#  _____   ___ _____  ______ ___________ ___  _   _ _    _____ _____ 
# /  __ \ / _ \_   _| |  _  \  ___|  ___/ _ \| | | | |  |_   _/  ___|
# | /  \// /_\ \| |   | | | | |__ | |_ / /_\ \ | | | |    | | \ `--. 
# | |    |  _  || |   | | | |  __||  _||  _  | | | | |    | |  `--. \
# | \__/\| | | || |   | |/ /| |___| |  | | | | |_| | |____| | /\__/ /
#  \____/\_| |_/\_/   |___/ \____/\_|  \_| |_/\___/\_____/\_/ \____/ 
# 
# https://patorjk.com/software/taag/#p=display&f=Doom&t=DEFAULTS
#
# 

variable "region" {
  type        = string
  description = "The default region for the application / deployment"
  default     = "af-south-1"

  validation {
    condition = contains([
      "eu-central-1",
      "eu-west-1",
      "eu-west-2",
      "eu-south-1",
      "eu-west-3",
      "eu-north-1",
      "af-south-1"
    ], var.region)
    error_message = "Invalid region provided."
  }
}

variable "environment" {
  type        = string
  description = "Will this deploy a development (dev) or production (prod) environment"

  validation {
    condition     = contains(["dev", "prd"], var.environment)
    error_message = "Stage must be either 'dev' or 'prd'."
  }
}

variable "code_repo" {
  type        = string
  description = "Points to the source code used to deploy the resources {{repo}} [{{branch}}]"
}

variable "namespace" {
  type        = string
  description = "Used to identify which part of the application these resources belong to (auth, infra, api, web, data)"
  default     = "infra"

  validation {
    condition     = contains(["sec", "auth", "infra", "api", "web", "data"], var.namespace)
    error_message = "Namespace needs to be : \"sec\", \"auth\", \"infra\", \"api\" or \"web\"."
  }
}

variable "application_name" {
  type = object({
    short = string
    long  = string
  })
  description = "Used in naming conventions, expecting an object"
  default = {
    long  = "AfroCentric-PHI"
    short = "phi"
  }

  validation {
    condition     = length(var.application_name["short"]) <= 5
    error_message = "The application_name[\"short\"] needs to be less or equal to 5 chars."
  }
}

variable "nukeable" {
  type        = bool
  description = "Can these resources be cleaned up. Will be ignored for prod environments"
  default     = false
}

variable "client_name" {
  type = object({
    short = string
    long  = string
  })
  description = "Used in naming conventions, expecting an object"
  default = {
    long  = "AfroCentric"
    short = "act"
  }

  validation {
    condition     = length(var.client_name["short"]) <= 5
    error_message = "The client_name[\"short\"] needs to be less or equal to 5 chars."
  }
}

variable "purpose" {
  type        = string
  description = "Used for cost allocation purposes"
  default     = "product"

  validation {
    condition     = contains(["rnd", "client", "product", "self"], var.purpose)
    error_message = "Purpose needs to be : \"rnd\", \"client\", \"product\", \"self\"."
  }
}

variable "owner" {
  type        = string
  description = "Used to find resources owners, expects an email address"
  default     = "evan@cloudandthings.io"

  validation {
    condition     = can(regex("^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$", var.owner))
    error_message = "Owner needs to be a valid email address."
  }
}

variable "aws_account_id" {
  type        = string
  description = "Needed for Guards to ensure code is being deployed to the correct account"
}

variable "tags" {
  type        = map(string)
  description = "Default tags added to all resources, this will be added to the provider"

  default = {}
}


# #   ___  ____________   _   _  ___  ______  _____ 
# #  / _ \ | ___ \ ___ \ | | | |/ _ \ | ___ \/  ___|
# # / /_\ \| |_/ / |_/ / | | | / /_\ \| |_/ /\ `--. 
# # |  _  ||  __/|  __/  | | | |  _  ||    /  `--. \
# # | | | || |   | |     \ \_/ / | | || |\ \ /\__/ /
# # \_| |_/\_|   \_|      \___/\_| |_/\_| \_|\____/ 
# #
# # Variables specific to this app

variable "domain" {
  type        = string
  description = "Domain used for the application"
  default = "dev.phi.afrocentrictech.org"
}

# https://github.com/QloudX/terraform-AWS-Lambda-REST-API/blob/main/rest-api.tf
variable "api_endpoints" {
  type = any
  default = {
    "/auth/request_token" = { post = "act-phi-dev-infra-app-request-token" }
    "/backend/applications" = { post = "act-phi-dev-infra-app-applications" }
    "/backend/applications/attachments" = { post = "act-phi-dev-infra-app-applications-attachments" }
    "/backend/applications/questions" = { post = "act-phi-dev-infra-app-applications-questions" }
    "/backend/person" = { post = "act-phi-dev-infra-app-person" }
    "/backend/search/id_number" = { post = "act-phi-dev-infra-app-search-id_number" }
    "/backend/search/last_name" = { post = "act-phi-dev-infra-app-search-last_name" }
  }
}

variable "lambda_functions"{
  type = any
  default = {
    act-phi-dev-infra-app-request-token = {
        runtime = "nodejs20.x"
        handler = "index.handler"
    }
    act-phi-dev-infra-app-applications = {
        runtime = "nodejs20.x"
        handler = "index.handler"
    }
    act-phi-dev-infra-app-api-applications-attachments = {
        runtime = "nodejs20.x"
        handler = "index.handler"
    }
    act-phi-dev-infra-app-api-applications-questions = {
        runtime = "nodejs20.x"
        handler = "index.handler"
    }
    act-phi-dev-infra-app-person = {
        runtime = "nodejs20.x"
        handler = "index.handler"
    }
    act-phi-dev-infra-app-search-id_number = {
        runtime = "nodejs20.x"
        handler = "index.handler"
    }
    act-phi-dev-infra-app-api-search-last_name = {
        runtime = "nodejs20.x"
        handler = "index.handler"
    }
  }
}

variable "api_gateway_stage_name" {
  type        = string
  description = "API gateway stage name"
}

variable "api_function_timeout" {
  type    = number
  default = 30
}

variable "api_function_memory_size" {
  type    = number
  default = 512
}

variable "create_db_instance" {
  type    = bool
  default = false
}

variable "refresh_token_validity_minutes" {
  type        = number
  description = "The refresh token validity in minutes."
  default     = 480
}

variable "ssh_list" {
  type = list(string)
  description = "The list of IP addresses that are allowed to SSH into the EC2 bastion host"
}

variable "bastion_ami_id" {
  type = string
  description = "The AMI ID to be used for the Bastion Host"
}

variable "bastion_key_pair" {
  type = string
  description = "The key pair to be used for the Bastion Host"
  default = "phi-api-key-pair"
  
}

# #  _   _______  _____   _   _  ___  ______  _____ 
# # | | | | ___ \/  __ \ | | | |/ _ \ | ___ \/  ___|
# # | | | | |_/ /| /  \/ | | | / /_\ \| |_/ /\ `--. 
# # | | | |  __/ | |     | | | |  _  ||    /  `--. \
# # \ \_/ / |    | \__/\ \ \_/ / | | || |\ \ /\__/ /
# #  \___/\_|     \____/  \___/\_| |_/\_| \_|\____/ 
# #
# # Variables specific to the VPC creation


variable "public_web_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
 
variable "private_app_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "private_data_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
}

variable "azs" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["af-south-1a", "af-south-1b", "af-south-1c"]
}