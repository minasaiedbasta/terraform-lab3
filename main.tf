provider "aws" {
  region = var.region
}

module "network" {
  source = "./modules/network"
  vpc_cidr_block = var.vpc_cidr_block
  availability_zones = var.availability_zones
  subnets = var.subnets
}

module "loadbalancer" {
  source = "./modules/loadbalancer"
  vpc_id = module.network.vpc_id
  nginx_sg_id = module.instance.nginx_sg_id
  az1_public_subnet_id = module.network.az1_public_subnet.id
  az1_private_subnet_id = module.network.az1_private_subnet.id
  az2_public_subnet_id = module.network.az2_public_subnet.id
  az2_private_subnet_id = module.network.az2_private_subnet.id
  az1_public_instance_id = module.instance.az1_public_instance_id
  az2_public_instance_id = module.instance.az2_public_instance_id
  az1_private_instance_id = module.instance.az1_private_instance_id
  az2_private_instance_id = module.instance.az2_private_instance_id
}

module "instance" {
  source = "./modules/instance"
  instance_type = var.instance_type
  private_load_balancer_dns = module.loadbalancer.private_load_balancer_dns
  public_lb_sg_id = module.loadbalancer.public_lb_sg_id
  private_lb_sg_id = module.loadbalancer.private_lb_sg_id
  vpc_id = module.network.vpc_id
  az1_public_subnet_id = module.network.az1_public_subnet.id
  az1_private_subnet_id = module.network.az1_private_subnet.id
  az2_public_subnet_id = module.network.az2_public_subnet.id
  az2_private_subnet_id = module.network.az2_private_subnet.id
  public_key_location = var.public_key_location
  private_key_location = var.private_key_location
}