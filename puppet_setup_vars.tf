variable "region" {}
variable "vpc_id" {}
variable "subnet_id" {}

variable "ports" {
    type = "list"
    default = ["22", "8140", 0]
}

variable "ami" {
    type = "map"
    default = {
        "us-east-1" = "ami-064a0193585662d74"
        "us-east-2" = "ami-021b7b04f1ac696c2"
        "us-west-1" = "ami-056d04da775d124d7"
        "us-west-2" = "ami-09a3d8a7177216dcf"
        "ap-south-1" = "ami-0cf8402efdb171312"
    }
}
variable "cidr_block_all_traffic" {
    default = "0.0.0.0/0"
}
variable "key_pair_name" {
    default = "puppet_ec2_key"
}

variable "instance_type" {
    default = "t2.micro" 
}

variable "tags"{
    type = "list"
    default = ["Master", "Agent"]
}

output "ec2_public_ip" {
  value = "${aws_instance.PuppetServer.*.public_ip}"
}

output "ec2_private_ip" {
  value = "${aws_instance.PuppetServer.*.private_ip}"
}

output "ec2_public_dns" {
  value = "${aws_instance.PuppetServer.*.public_dns}"
}

output "ec2_private_dns" {
  value = "${aws_instance.PuppetServer.*.private_dns}"
}
