resource "aws_security_group" "nginx_sg" {
  vpc_id = var.vpc_id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    #security_groups = [ var.public_lb_sg_id ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name = "${terraform.workspace}-nginx-sg"
  }
}

resource "aws_security_group" "apache_sg" {
  vpc_id = var.vpc_id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [ var.private_lb_sg_id ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name = "${terraform.workspace}-apache-sg"
  }
}

data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["al2023-ami-*-x86_64"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name = "ssh-key"
  public_key = "${file(var.public_key_location)}"
}

resource "aws_instance" "az1_public_instance" {
  ami = data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  subnet_id = var.az1_public_subnet_id
  key_name = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true

/*
  connection {
    type     = "ssh"
    host     = self.public_ip
    user     = "ec2-user"
    private_key = file(var.private_key_location)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update",
      "sudo yum install -y nginx",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx",
    ]
  }

  provisioner "file" {
    content = <<-EOT
      # this the custom configuration to forward the traffic from proxy to the private load balancer
      server {
          listen 80;
          listen [::]:80;
          server_name ${var.private_load_balancer_dns};
          location / {
              proxy_pass ${var.private_load_balancer_dns};
          }
      }
    EOT
    destination = "/etc/nginx/nginx.conf"
  }
  */

  connection {
    type     = "ssh"
    host     = self.public_ip
    user     = "ec2-user"
    private_key = file(var.private_key_location)
  }

  provisioner "local-exec" {
    command = "echo public-ip1  ${self.public_ip} >> all-ips.txt "
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update
    sudo yum install -y nginx
    sudo echo "user nginx;
    worker_processes auto;

    error_log /var/log/nginx/error.log;
    pid /var/run/nginx.pid;

    events {
        worker_connections 1024;
    }

    http {
        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                        '$status $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" "$http_x_forwarded_for"';

        access_log /var/log/nginx/access.log main;

        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_timeout 65;
        types_hash_max_size 2048;

        include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/sites-enabled/*;
        
        # this the custom configuration to forward the traffic from proxy to the private load balancer
        server {
            listen 80;
            listen [::]:80;
            server_name ${var.private_load_balancer_dns};
            location / {
                proxy_pass http://${var.private_load_balancer_dns};
            }
        }
    }" > /etc/nginx/nginx.conf
    sudo systemctl enable nginx
    sudo systemctl start nginx
  EOF
  

  tags = {
    Name = "${terraform.workspace}-az1-public-instance"
  }
}

resource "aws_instance" "az2_public_instance" {
  ami = data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  subnet_id = var.az2_public_subnet_id
  key_name = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true

  connection {
    type     = "ssh"
    host     = self.public_ip
    user     = "ec2-user"
    private_key = file(var.private_key_location)
  }

  provisioner "local-exec" {
    command = "echo public-ip2  ${self.public_ip} >> all-ips.txt "
  }


  user_data = <<-EOF
    #!/bin/bash
    sudo yum update
    sudo yum install -y nginx
    sudo echo "user nginx;
    worker_processes auto;

    error_log /var/log/nginx/error.log;
    pid /var/run/nginx.pid;

    events {
        worker_connections 1024;
    }

    http {
        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                        '$status $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" "$http_x_forwarded_for"';

        access_log /var/log/nginx/access.log main;

        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_timeout 65;
        types_hash_max_size 2048;

        include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/sites-enabled/*;
        
        # this the custom configuration to forward the traffic from proxy to the private load balancer
        server {
            listen 80;
            listen [::]:80;
            server_name ${var.private_load_balancer_dns};
            location / {
                proxy_pass http://${var.private_load_balancer_dns};
            }
        }
    }" > /etc/nginx/nginx.conf
    sudo systemctl enable nginx
    sudo systemctl start nginx
  EOF


  tags = {
    Name = "${terraform.workspace}-az2-public-instance"
  }
}

resource "aws_instance" "az1_private_instance" {
  ami = data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  subnet_id = var.az1_private_subnet_id
  key_name = aws_key_pair.ssh_key.key_name
  user_data = <<-EOF
    #!/bin/bash
    sudo yum update
    sudo yum install -y httpd
    sudo systemctl enable httpd
    sudo systemctl start httpd
  EOF

  tags = {
    Name = "${terraform.workspace}-az1-private-instance"
  }
}

resource "aws_instance" "az2_private_instance" {
  ami = data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  subnet_id = var.az2_private_subnet_id
  key_name = aws_key_pair.ssh_key.key_name
  user_data = <<-EOF
    #!/bin/bash
    sudo yum update
    sudo yum install -y httpd
    sudo systemctl enable httpd
    sudo systemctl start httpd
  EOF

  tags = {
    Name = "${terraform.workspace}-az2-private-instance"
  }
}