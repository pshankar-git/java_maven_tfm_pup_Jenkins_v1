provider "aws" {
    region = "us-east-1"
    access_key = "AKIATOLN4SYY5NVPCTEP"
    secret_key = "ju2RAR2DtdQSMDcdNsuDZZC73JVH52qqfcEcUyMG"
}

# Creaing EC2 instance

resource "aws_instance" "tf_example" {
    ami = "ami-08111162"
    instance_type = "t2.micro"

tags = {
    Name = "Terraform_Example"
}
}


