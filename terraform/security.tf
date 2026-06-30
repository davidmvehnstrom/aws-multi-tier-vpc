resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "allow from my IP"
  vpc_id      = aws_vpc.mvc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mvc-sg-bastion"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "allow 80/443 from anywhere"
  vpc_id      = aws_vpc.mvc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mvc-sg-alb"
  }
}

resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  description = "allow 80 from alb_sg and 22 from bastion_sg"
  vpc_id      = aws_vpc.mvc.id
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mvc-sg-app"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "allow 3306 from app_sg"
  vpc_id      = aws_vpc.mvc.id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mvc-sg-db"
  }
}

