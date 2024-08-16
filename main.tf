# main.tf

# Налаштування провайдера AWS
provider "aws" {
  region = "eu-west-1"
}

# Виклик модуля для створення мережевої інфраструктури AWS
module "aws_network" {
  source               = "./modules/aws_network"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  allow_ports          = var.allow_ports
}

module "aws_alb" {
  source = "./modules/aws_alb"
  security_groups    = [module.aws_network.dev_sg]  # Як список
  public_subnets     = module.aws_network.public_subnet_ids
  vpc_id             = module.aws_network.vpc_id   # Додано vpc_id
}

# Отримання останнього доступного образу AMI для Ubuntu 20.04
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}
