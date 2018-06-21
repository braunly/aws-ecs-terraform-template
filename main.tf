# AWS provider
provider "aws" {
	region = "eu-west-2"
}

# Launch configuration for autoscaling group
resource "aws_launch_configuration" "ecs-launch-configuration" {
	name = "ecs-launch-configuration"
	image_id = "ami-3622cf51"  # eu-west-2 ecs optimized ami
	instance_type = "t2.micro"
	
	root_block_device {
		volume_type = "standart"
		volume_size = 100
		delete_on_termination = true
	}
	
	lifecycle {
		create_before_destroy = true
	}
	
	associate_public_ip_address = "false"
	key_name = "testone"
}

# Creates autoscaling group
resource "aws_autoscaling_group" "ecs-autoscaling-group" {
	max_size = "2"
	min_size = "1"
	
	launch_configuration = "${aws_launch_configuration.ecs-launch-configuration.name}"
	
	tag {
		key = "Name"
		value = "ecs-inc-25"
		propagate_at_launch = true
	}
}

# Creates ECS cluster
resource "aws_ecs_cluster" "ecs-cluster" {
	name = "inc25ecscluster"
}


# Data source with task definition for ECS service
data "aws_ecs_task_definition" "ecs-task-definition" {
  task_definition = "${aws_ecs_task_definition.ecs-task-definition.family}"
}


# Creates task definition
resource "aws_ecs_task_definition" "ecs-task-definition" {
  family = "test"

  container_definitions = <<DEFINITION
[
  {
    "cpu": 128,
    "essential": true,
    "image": "ubuntu",
    "memory": 128,
    "memoryReservation": 64,
    "name": "test"
  }
]
DEFINITION
}

# Creates ECS service with two instances
resource "aws_ecs_service" "ecs-service" {
  name          = "test"
  cluster       = "${aws_ecs_cluster.ecs-cluster.id}"
  desired_count = 2

  task_definition = "${aws_ecs_task_definition.ecs-task-definition.family}:${max("${aws_ecs_task_definition.ecs-task-definition.revision}", "${data.aws_ecs_task_definition.ecs-task-definition.revision}")}"
}
