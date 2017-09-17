/*Terraform Configuration file for Simple Web Server publishing  Hello, World Web Page on port 8080 */

#Provider details
 provider "aws" { 
     region = "eu-west-2"
   }

#Web Instance Configuration
 resource "aws_instance" "app1" { 
   ami  = "ami-996372fd"
   instance_type = "t2.micro"
   vpc_security_group_ids = ["${aws_security_group.websecgrp.id}"]

#Simple Web Architecture Configuration - Bash Script
 user_data = <<-EOF
             #!/bin/bash
             echo "Hello, World" > index.html
             nohup busybox httpd -f -p 8080 &
             EOF

 tags {
   Name = "app1-svr"
  }
}

#Creates Security Group for EC2 web server traffic
 resource "aws_security_group" "websecgrp" {
    name = "websecgrp-SG"
    
    ingress {
       from_port  = 8080
       to_port    = 8080
       protocol   = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
     }
 }




