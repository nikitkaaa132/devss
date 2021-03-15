provider "aws" {
  region = "eu-central-1"
}
resource "aws_instance" "jenkins_server" {
  ami = "ami-0767046d1677be5a0"
  instance_type = "t2.micro"
  key_name = "aws_key"
  vpc_security_group_ids = [aws_security_group.my_jenkins_server.id]
  user_data = <<EOF
#!/bin/bash
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > \
    /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install jenkins -y
sudo apt-get install openjdk-11-jdk -y
echo "Password to jenkins "
cat  /var/lib/jenkins/secrets/initialAdminPassword
EOF
//sudo reboot
tags = {
  Name = "Jenkins Server"
}
connection  {
    host= self.public_ip
    type = "ssh"
    user = "ubuntu"
    private_key = file("/home/nikita/Course/secret/aws_key")
  }
}

resource "aws_security_group" "my_jenkins_server" {
  name = "WebServer Security Group"
  description = "My First SG"

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkins Server Security Group"
  }
}