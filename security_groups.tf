############################
# Security Groups (4 layers)
############################

# --- ALB: HTTP 80 from internet ---
resource "aws_security_group" "alb" {
  name        = "${var.project}-sg-alb"
  description = "ALB - HTTP from internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-sg-alb" }
}

# --- Backend EC2: app port from ALB SG only ---
resource "aws_security_group" "backend" {
  name        = "${var.project}-sg-backend"
  description = "Backend EC2 - only from ALB SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "App port from ALB only"
    from_port       = var.backend_port
    to_port         = var.backend_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Optional: SSH for debugging only from your IP
  dynamic "ingress" {
    for_each = var.key_name == "" ? [] : [1]
    content {
      description = "SSH from admin"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.ssh_cidr]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-sg-backend" }
}

# --- Frontend EC2: HTTP from internet, SSH only from admin ---
resource "aws_security_group" "frontend" {
  name        = "${var.project}-sg-frontend"
  description = "Frontend EC2 - HTTP from internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = var.key_name == "" ? [] : [1]
    content {
      description = "SSH from admin"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.ssh_cidr]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-sg-frontend" }
}

# --- RDS: MySQL 3306 only from backend SG ---
resource "aws_security_group" "rds" {
  name        = "${var.project}-sg-rds"
  description = "RDS - only from backend SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from backend SG only"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.backend.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-sg-rds" }
}
