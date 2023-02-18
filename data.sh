#!/bin/bash
sudo yum update -y 
sudo yum -y install docker 
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
sudo docker run -p 8080:80 nginx
sudo yum install openssh -y 
sudo service sshd restart
