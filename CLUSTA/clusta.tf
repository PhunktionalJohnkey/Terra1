#Configuration for Web Server Cluster

#Launch Configuration details

 resource "aws_launch_configuration" "phunky-launchconfig" {
      image-id      = "${var.ami}"
      instance_type = "t2.micro"
      security_groups = ["${aws_security_group_websecgrp.id}"]
      
      user_data = <<-EOF
                  #!/bin/bash
                  echo "Hello, World" > index.html
                  nohup busybox httpd -f -p "${var.server_port}" &
                  EOF
#Metaparameter defining how this resource should be handled by the ASG
      lifecycle {
          create_before_destroy = true
        }
    }

#Create AWS Security Group with lifecycle because referenced in launch_config

  resource "aws_security_group" "websecgrp" {
       name = "websecgrp-SG"
       
       ingress {
          from_port  =  "${var.server_port}"
          to_port    =  "${var.server_port}"
          protocol   =  "tcp"
          cidr_block =  ["0.0.0.0/0"]
        }
       
       lifecycle {
          create_before_destroy = true
        }
   }

#Create ASG 
 
 resource "aws_autoscaling_group" "clusta-ag" {
    launch_configuration = "${aws_launch_configuration.phunky-launchconfig.id}"
    availability_zones ['${data.aws_availability_zones.all.names}"]

    load_balancers     =  ["${aws_elb.asg1-elb.name}']
    health_check_type  =  "ELB"

    min_size = 2 
    max_size = 6

    tag {
        key        =  "Name"
        value      =  "clusta-asg1"
        propagate_at_launch = true
      }
  }

#Security group to allow elb incoming traffic
 
 resource "aws_security_group" "elb" {
   name = "elbsecgrp-SG"

   ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
   
   egress {
     from_port = 0
     to_port   = 0
     protocol  = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
    } 
 }

#Create Load Balancer to distribute incoming Web server traffic to allow for a higly scalable infrastructure

 resource "aws_elb" "asg1-elb" {
    name    = "asg1-loadbalancer"
    availability_zones = ["${data.aws_availability_zones.all.names}"]
    security_groups = ["${aws_security_group.elb.id}"]

#Create Listener instructing ELB how to route traffic
    listener {
       lb_port = "${var.lb_port}"
       lb_protocol = "http"
       instance_port = "${var.server_port}"
       instance_protocol = "http"
      }

#Create ELB EC2 Instances Health Check 
    health_check {
      healthy_threshold    = 2
      unhealthy_threshold  = 2
      timeout              = 3
      interval             = 30
      target               = "HTTP:${var.server_port}/"
     }

#Useful outputs

 output "elb_dns_name" {
    value = "${aws_elb.asg1-elb.dns_name}"
  }           
