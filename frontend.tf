############################
# Frontend: single EC2 in a public subnet
############################

resource "aws_instance" "frontend" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.frontend_instance_type
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.frontend.id]
  associate_public_ip_address = true
  key_name                    = var.key_name == "" ? null : var.key_name

  user_data = templatefile("${path.module}/user_data/frontend.sh.tftpl", {
    frontend_repo = var.frontend_dist_repo
    alb_dns       = aws_lb.app.dns_name
  })

  # Default AL2023 root is tiny; ng build + node_modules need more space
  root_block_device {
    volume_size           = 16
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data_replace_on_change = true

  tags = { Name = "${var.project}-frontend" }
}
