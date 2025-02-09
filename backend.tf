terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.50.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.2.0"
    }
  }
  required_version = ">= 1.0"
}


terraform {
  backend "s3" {
    bucket  = "sctp-ce8-tfstate"                            # Use the bucket name from your create-s3-bucket setup
    key     = "terraform/ce8-coaching-16/terraform.tfstate" # Unique key for your state file
    region  = "ap-southeast-1"
    encrypt = true
  }
}
