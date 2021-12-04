#!/bin/bash
sudo apt update 
sudo apt install docker.io -y
sudo usermod -aG docker ubuntu
docker run -itd -p 8080:80 nginx:1.18
