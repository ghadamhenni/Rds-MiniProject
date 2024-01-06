

provider "aws" {
  region = "us-east-1"
  //access_key = ""
  //secret_key = ""
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames=true
  tags={
    Name="rdsVpc"
  }
}

data "aws_availability_zones" "available"{
state= "available"
}

resource "aws_internet_gateway" "Rds_igw" {
  vpc_id=aws_vpc.my_vpc.id
  tags = {Name="rds_gateway"
  
  }
}

resource "aws_subnet" "public_subnet"{
    count=var.subnet_count.public
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = var.public_subnet_cidr_blocks[count.index]
    availability_zone = data.aws_availability_zones.available.names[count.index]
tags = {Name="public_subnet_count"}
}
resource "aws_subnet" "private_subnet"{
    count=var.subnet_count.private
    vpc_id = aws_vpc.my_vpc.id 
    cidr_block = var.private_subnet_cidr_blocks[count.index]
    availability_zone = data.aws_availability_zones.available.names[count.index]
tags = {Name="private_subnet_count"}
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block="0.0.0.0/0"
    gateway_id=aws_internet_gateway.Rds_igw.id
               
  }
  
}

resource "aws_route_table_association" "public" {
  count=var.subnet_count.public
  route_table_id = aws_route_table.public_route_table.id
  subnet_id=aws_subnet.public_subnet[count.index].id
}


resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  
}

resource "aws_route_table_association" "private" {
  count=var.subnet_count.private
  route_table_id = aws_route_table.private_route_table.id
  subnet_id=aws_subnet.private_subnet[count.index].id
}

resource "aws_security_group" "web_sg" {
  description = "security group"
  vpc_id = aws_vpc.my_vpc.id
   ingress {
     description="Allow_http"
     from_port="80"
     to_port="80"
     protocol="tcp"
     cidr_blocks=["0.0.0.0/0"]
}
   ingress {
     description="Allow_https"
     from_port="443"
     to_port="443"
     protocol="tcp"
     cidr_blocks=["0.0.0.0/0"]
 }
   ingress {
     description="Allow_ssh"
     from_port="22"
     to_port="22"
     protocol="tcp"
     cidr_blocks=["0.0.0.0/0"]
}
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
     description="Allow_https"
     from_port="443"
     to_port="443"
     protocol="tcp"
     cidr_blocks=["0.0.0.0/0"]
 }
tags = {
  Name="webSecurityGroup"
}
}
resource "aws_security_group" "db_sg" {
  
  description = "security group for db"
  vpc_id = aws_vpc.my_vpc.id
   
   ingress {
     description="Allow_mysql"
     from_port="3306"
     to_port="3306"
     protocol="tcp"
     cidr_blocks=["0.0.0.0/0"]


   }

tags = {
  Name="dataBaseSecurityGroup"
}
}
resource "aws_db_subnet_group" "db_subnet_group" {
  subnet_ids=[for subnet in aws_subnet.private_subnet : subnet.id]
}

resource "aws_db_instance" "myDBinstance" {
    allocated_storage = var.setting.database.allocated_storage
    engine=var.setting.database.engine
    engine_version = var.setting.database.engine_version
    instance_class = var.setting.database.instance_class
    db_name = var.setting.database.db_name
    username=var.db_username
    password=var.db_password
    skip_final_snapshot = var.setting.database.skip_final_snapshot
    vpc_security_group_ids = [aws_security_group.db_sg.id]
    db_subnet_group_name = aws_db_subnet_group.db_subnet_group.id
}

resource "aws_instance" "webPage" {
  count=var.setting.web_app.count
  instance_type = var.setting.web_app.instance_type
  subnet_id = aws_subnet.public_subnet[count.index].id
  //key_name= aws_key_pair.deployer.key_name
  ami = var.ami_id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
tags={
    Name="InstanceForRds"
}
}
resource "aws_eip" "Web_elasticIp" {
    count=var.setting.web_app.count
  instance=aws_instance.webPage[count.index].id
  tags={Name="WebElasticIpAddress"}
}
//resource "aws_key_pair" "deployer" {
  //key_name   = "my-key-file"
  //public_key = ""


//}