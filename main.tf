


#  1. create a VPC  - 10.81.0.0/16

resource "aws_vpc" "prod_vpc" {
    cidr_block = "10.81.0.0/16"
    instance_tenancy = "default"

  tags = {
    Name = "prod_vpc"
  }
}

# 2. Create Internet Gateway 


resource "aws_internet_gateway" "prod_igw" {

    vpc_id = aws_vpc.prod_vpc.id
     
    tags = {
    Name = "prod_igw"
  }
}

 # 3. Create Custom Route Table 

 resource "aws_route_table" "prod_rt" {
    vpc_id = aws_vpc.prod_vpc.id

    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod_igw.id
  }

    tags = {
    Name = "prod_rt"
  }

 }

# 4. Create a Subnet  -- 10.81.3.0/24

resource "aws_subnet" "prod_sn" {

vpc_id = aws_vpc.prod_vpc.id
cidr_block = "10.81.3.0/24"

 tags = {
    Name = "prod_sn"
  }

}

#  5. Associate subnet with Route Table 

resource "aws_route_table_association" "prod_rta" {
  
  route_table_id = aws_route_table.prod_rt.id
  subnet_id = aws_subnet.prod_sn.id

}

# 6. Create Security Group to allow port 22,80,443 or all ports , traffic  


resource "aws_security_group" "prod_sg" {
  
  vpc_id = aws_vpc.prod_vpc.id

 # Inbound rules for 80 , 443 , 22 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to the world
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to the world (restrict if needed)
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to the world
  }


  # Outbound rule (allow all traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }

tags = {
    Name = "prod_sg"
  }

}

# 7. Create a network interface with an ip in the subnet that was created in step 4  

resource "aws_network_interface" "prod_nic" {
  subnet_id       =  aws_subnet.prod_sn.id
  private_ips     = ["10.81.3.33"]
  security_groups = [aws_security_group.prod_sg.id]

tags = {
    Name = "prod_nic"
  }
  
}


# 8. Assign an elastic IP to the network interface created in step 7 

resource "aws_eip" "name" {
  domain = "vpc"
  network_interface         = aws_network_interface.prod_nic.id
  associate_with_private_ip = "10.81.3.33"

  tags = {
    Name = "prod_eip"
  }
    
}

# 9. Create an ec2  server - LAUNCH APLICATION IN IT 

resource "aws_instance" "prod" {

 ami = "ami-0cbbe2c6a1bb2ad63"
 instance_type = "t2.micro"
 key_name = "Talha"
 user_data = "${file("fbscript.sh")}"

  network_interface {
    network_interface_id = aws_network_interface.prod_nic.id
    device_index         = 0
  }
tags = {
    Name = "prod"
  }
}

output "ec2_pub_ip" {
  value = aws_instance.prod.public_ip
}
