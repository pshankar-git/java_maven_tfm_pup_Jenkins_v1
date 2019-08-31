variable "region" {}
variable "vpc_id" {}
variable "subnet_id" {}

variable "ports" {
    type = "list"
    default = ["22", "8140", 0]
}

variable "cidr_block_all_traffic" {
    default = "0.0.0.0/0"
}
variable "key_pair_name" {}

variable "public_key" {}

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
