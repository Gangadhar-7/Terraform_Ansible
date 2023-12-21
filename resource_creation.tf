
locals {
  vpc_id           = "vpc-05df269ff45faede9"
  subnet_id        = "subnet-0bc825fd411301584"
  ssh_user         = "ubuntu"
  key_name         = "ansible"
  private_key_path = "./ansible.pem"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "nginx" {
  name   = "nginx_access"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx" {
  ami                         = "ami-079db87dc4c10ac91"
  subnet_id                   = "subnet-0bc825fd411301584"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.nginx.id]
  key_name                    = local.key_name

}
connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = "ansible"
      host        = aws_instance.nginx.public_ip
    }
  provisioner "remote-exec" {
    inline = ["ansible-playbook  -i ${aws_instance.nginx.public_ip}, --private-key ${"./ansible.pem"} nginx.yaml" ]

  } 

















































# pipeline {
#     agent any
#     environment {
#         DOCKER_REGISTRY = 'gangadhar0416' 
#         IMAGE_NAME = 'nodejs_app' // Replace with your desired image name
#     }

#     tools {
        
#         nodejs "nodejs"
#     }

#     stages {
#         stage('Build') {
#             steps {
#                 // Get some code from a GitHub repository
#                 git 'https://github.com/Gangadhar-7/docker-demo.git'

#                 sh 'npm install --only=dev'
#                 sh 'npm test'
#             }
#         }
        
#          stage('Docker build and push') {
#             steps {
#                 script {
#                     def dockerImage = docker.build("${DOCKER_REGISTRY}/${IMAGE_NAME}")
#                     dockerImage.push()
#                 }
#             }
#         }
            
        

            

#     }
# }