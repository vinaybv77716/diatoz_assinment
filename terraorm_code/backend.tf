
terraform {
  backend "s3" {
    bucket = "diatozterraform"
    key    = "terraform.tfstate"
    region = "us-east-1"
 #   encrypt = true
#    dynamodb_table = "terraform-state-lock-dynamo"
    }
  }

