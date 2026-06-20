locals {
  name = "practice-ecs"
}

data "aws_route53_zone" "zone" {
  name         = var.domain_name
  private_zone = false

}
#calling acm certificate
data "aws_acm_certificate" "cert" {
  domain      = var.domain_name
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

module "vpc" {
  source              = "./modules/vpc"
  name                = local.name
  acm_certificate_arn = data.aws_acm_certificate.cert.arn
}

module "alb" {
  source       = "./modules/alb"
  key_name     = module.vpc.private_key
  name         = local.name
  acm_cert_arn = data.aws_acm_certificate.cert.arn
  public_subnets = [
    module.vpc.public_subnet_ids["pub2"],
    module.vpc.public_subnet_ids["pub3"]
  ]
  domain = var.domain_name
  vpc_id = module.vpc.vpc_id
}

module "ecr" {
  source = "./modules/ecr"
}

module "autoscale" {
  source       = "./modules/ecs/Autoscaling"
  max_capacity = 5
  min_capacity = 1
  cluster_name = module.cluster.ecs_cluster_name
  name         = "${local.name}-service"
}

module "cluster" {
  source = "./modules/ecs/Cluster"
  name   = "${local.name}-cluster"
}

module "service" {
  source = "./modules/ecs/Service"
  subnets_id = [
    module.vpc.public_subnet_ids["pub2"],
    module.vpc.public_subnet_ids["pub3"]
  ]
  container_name      = "appContainer"
  container_port      = 3000
  ecs_cluster_id      = module.cluster.ecs_cluster_id
  arn_target_group    = module.alb.arn_target_group
  arn_task_definition = module.task_definition.arn_task_definition
  name                = "${local.name}-service"
  iam_role_ecs = module.iam.ecs_task_role_arn
  desired_tasks       = 1
  arn_security_group  = "arn:aws:ec2:eu-west-2:127214197057:security-group/sg-07ef69ab1f08e3b99"
}

module "task_definition" {
  source             = "./modules/ecs/TaskDefinition"
  cpu                = 256
  memory             = "512"
  region             = "eu-west-2"
  docker_repo        = module.ecr.ecr_repository_url
  container_port     = 3000
  container_name     = "appContainer"
  name               = "${local.name}-task-def"
  execution_role_arn = module.iam.ecs_task_execution_role_arn

}

module "iam" {
  source = "./modules/iam"
}


variable "domain_name" {
  default = "mfon21.space"
}
