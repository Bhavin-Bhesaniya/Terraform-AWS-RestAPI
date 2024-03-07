bucket_name = "restapi-bucket-state"

vpc_cidr             = "11.0.0.0/16"
vpc_name             = "aws-vpc-restapi"
cidr_public_subnet   = ["11.0.1.0/24", "11.0.2.0/24"]
cidr_private_subnet  = ["11.0.3.0/24", "11.0.4.0/24"]
ap_availability_zone = ["ap-south-1a", "ap-south-1b"]

public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCdsD6SGfBau3sfxwLp9R6IXxq2nALMUH/xnjaQibWldyGorEtvR0kCXUEk3iZSPe1GANjgHxz1HLMKKktAW6j32gRGapIux7EzlpAmcduko8u2woagvQgHipTw8d1gY+PynaXNlh3T6e5m2pO8DzUW8VGFbGh0V71DGW5WQ1GuTJeFVHGFFDHKEdUSiQzb2NEkX2dBsZFpGy0s3v/pYukmf7t/fqPp6uzLob4Yq7TCOkROMadojB3oN48FPUWbIqvXNHGCUwntTh5A5xgB8SM8AHqQotWpAUcwm3kuRwHVkR/UD64uE3T9nwhJ084lodka5vzZ9skrXvLq9CigQ8Wj3WwWDij9q8n6L79d9bKt6RHIdUsD+Z06VQy9dpJw+uoENrxWY5zIHysoggAmZDTSDjvFNhnjNUFLzaS152belSD6DKhjVkkaOTDLU3P1mzkSyDiluUV26csvIcJTmQtzNmgI3Q3EqOOA4b9ZvhGkAUVgzcGPjMUJrlE25jkwG28= bkbhe@Bhavin"
ec2_ami_id = "ami-03bb6d83c60fc5f7c"

ec2_user_data_install_apache = ""