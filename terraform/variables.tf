# Région AWS
variable "aws_region" {
  description = "Région AWS"
  type        = string
  default     = "us-east-1"
}

# Type d'instance
variable "instance_type_master" {
  description = "Type instance control-plane"
  type        = string
  default     = "t3.medium"
}

variable "instance_type_worker" {
  description = "Type instance workers"
  type        = string
  default     = "t3.large"
}

# Clé SSH
variable "key_name" {
  description = "Nom de la clé SSH"
  type        = string
  default     = "mspr-key"
}

# AMI
variable "ami_id" {
  description = "ID de l'AMI Ubuntu 22.04"
  type        = string
  default     = "ami-0c7217cdde317cfec"
}

# CIDR VPC
variable "vpc_cidr" {
  description = "CIDR du VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# CIDR Subnet
variable "subnet_cidr" {
  description = "CIDR du subnet public"
  type        = string
  default     = "10.0.1.0/24"
}

# Projet
variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "mspr-cogip"
}