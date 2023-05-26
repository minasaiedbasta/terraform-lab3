#!/bin/bash
yum update -y
yum install -y httpd
echo "This server from public subnet" > /var/www/html/index.html
systemctl start httpd
systemctl enable httpd