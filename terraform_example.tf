provider "aws" {
    region = "us-east-1"
    access_key = "AWS_ACCESS_KEY"
    secret_key = "AWS_SECRET_KEY"
}

# Creaing EC2 instance

resource "aws_instance" "tf_example" {
    ami = "ami-08111162"
    instance_type = "t2.micro"

tags = {
    Name = "Terraform_Example"
}
}


