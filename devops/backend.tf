
terraform {
 backend "s3" {
   bucket = "diatozterraform1"
   key    = "vinay.tfstate"
   region = "us-east-1"

   }
 }

