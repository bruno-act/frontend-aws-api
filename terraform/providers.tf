provider "random" {}

provider "aws" {
  region = var.region

  default_tags {
    tags = local.mandatory_tags
  }
}

provider "aws" {
  alias  = "acm"
  region = "us-east-1"

  default_tags {
    tags = local.mandatory_tags
  }
}