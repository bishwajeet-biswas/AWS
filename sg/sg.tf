##variables

variable "vpc_id" {}
variable "cidr_blocks" {}

resource "aws_security_group" "allow_rds" {
  name        = "allow_rds"
  description = "Allow rds inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "rds rule"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_rds"
  }
}

output "sg_created" {
  value             = aws_security_group.allow_rds.id
}