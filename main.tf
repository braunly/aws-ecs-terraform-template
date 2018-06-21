# AWS provider
provider "aws" {
	region = "eu-west-2"
}

# Creates ECS cluster
resource "aws_ecs_cluster" "ecs-cluster" {
	name = "inc25ecscluster"
}

resource "aws_iam_role" "ecs_inc25" {
	name = "ecs_inc25"
	assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
    "Effect": "Allow",
    "Principal": {
      "Service": "ec2.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  }
]
}
EOF
}

resource "aws_iam_role_policy" "ecs_inc25" { 
	name = "ecs_instance_role"
	role = "${aws_iam_role.ecs_inc25.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecs:StartTask"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "inc25" {
	name = "inc25_profile"
	roles = ["${aws_iam_role.ecs_inc25.name}"]
}

resource "aws_instance" "first" {
	ami = "ami-3622cf51"  # eu-west-2 ecs optimized ami
	instance_type = "t2.micro"
	
	key_name = "denysiuk"
	
	user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.ecs-cluster.name} >> /etc/ecs/ecs.config
EOF
  
	tags {
		Name = "INC-25-1"
	}
	
	iam_instance_profile = "${aws_iam_instance_profile.inc25.name}"
}

resource "aws_instance" "second" {
	ami = "ami-3622cf51"  # eu-west-2 ecs optimized ami
	instance_type = "t2.micro"
	
	key_name = "denysiuk"
	
	user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.ecs-cluster.name} >> /etc/ecs/ecs.config
EOF
	tags {
		Name = "INC-25-2"
	}
	
	iam_instance_profile = "${aws_iam_instance_profile.inc25.name}"
}

