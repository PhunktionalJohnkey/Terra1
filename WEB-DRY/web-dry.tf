/*Terraform Configuration file for Simple Web Server publishing Hello,World Web Page on port 8080. This time Parameterizing the config file with the use of variables */

#Provider details
 provider "aws" { 
     region = "${var.region}"
   }

#Web Instance Configuration
 resource "aws_instance" "app1" { 
   ami  = "${var.ami}"
   instance_type = "t2.micro"
   vpc_security_group_ids = ["${aws_security_group.websecgrp.id}"]

#Simple Web Architecture Configuration - Bash Script
 user_data = <<-EOF
             #!/bin/bash
             echo "Hello, World" > index.html
             nohup busybox httpd -f -p ${var.server_port}" &
             EOF

 tags {
   Name = "app1-svr"
  }
}

#Creates Security Group for EC2 web server traffic
 resource "aws_security_group" "websecgrp" {
    name = "websecgrp-SG"
    
    ingress {
       from_port  = "${var.server_port}"
       to_port    = "${var.server_port}"
       protocol   = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
     }
 }
