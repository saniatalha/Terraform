provider "aws" {
  
  region = "us-east-1"
  alias = "nv"
}

provider "aws" {
  
  region = "ap-south-1"
  alias = "mumbai"

}

resource "aws_instance" "sbox_nv" {

    ami = "ami-053a45fff0a704a47"
    instance_type = "t2.micro"
    key_name = "madhukey"  

    provider = aws.nv

     tags = {
    Name = "sbox-nv"
    }

}


resource "aws_instance" "sbox_mumbai" {

    ami = "ami-0ddfba243cbee3768"
    instance_type = "t2.micro"
    key_name = "mumbaib15"  

    provider = aws.mumbai

     tags = {
    Name = "sbox-mumbai"
    }

}