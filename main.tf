##VPC Creation
resource "aws_vpc" "myvpc" {
  cidr_block = var.mycidr
}

resource "aws_subnet" "mysubnet1" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "mysubnet2" {
  vpc_id = aws_vpc.myvpc.id
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  cidr_block = "10.0.1.0/24"
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "myRT" {
  vpc_id = aws_vpc.myvpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.myigw.id
  }
}

resource "aws_route_table_association" "myRTA1" {
  subnet_id = aws_subnet.mysubnet1.id
  route_table_id = aws_route_table.myRT.id
}

resource "aws_route_table_association" "myRTA2" {
  subnet_id = aws_subnet.mysubnet2.id
  route_table_id = aws_route_table.myRT.id
}

/*****My Security group
resource "aws_security_group" "mySg" {
  name = "mySecurityGroup"
  vpc_id = aws_vpc.myvpc.id
  ingress = for[ 

   ]
}***Security Group***/

resource "aws_security_group" "myinstanceSg" {
  name = "WebSg"
  vpc_id = aws_vpc.myvpc.id

  /*ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  } */
}

##S3 bucket creation
resource "aws_s3_bucket" "mybucket" {
  bucket = "pardhuterraform2024"
}

##EC2 creation
resource "aws_instance" "myec2a" {
  ami = "ami-0261755bbcb8c4a84"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.mysubnet1.id
  user_data = base64encode(file("userdata.sh"))
  vpc_security_group_ids = [aws_security_group.myinstanceSg.id]
}

resource "aws_instance" "myec2b" {
  ami = "ami-0261755bbcb8c4a84"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.mysubnet2.id
  vpc_security_group_ids = [aws_security_group.myinstanceSg.id]
}

/* Load balancer
resource "aws_lb" "myalb" {
  name = "myALB"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.myinstanceSg.id]
}

resource "aws_lb_target_group" "myTg" {
  name = "TG"
  vpc_id = aws_vpc.myvpc.id
  port = 80
  protocol = "HTTP"

  health_check {
    path="/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "myTGattch1" {
  target_group_arn = aws_lb_target_group.myTg.arn
  target_id = aws_instance.myec2a.id
  port = 80
}

resource "aws_lb_target_group_attachment" "myTGattch2" {
  target_group_arn = aws_lb_target_group.myTg.arn
  target_id = aws_instance.myec2b.id
  port = 80
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.myTg.arn
    type             = "forward"
  }
}

##Output
output "loadbalancerdns" {
  value = aws_lb.myalb.dns_name
} */