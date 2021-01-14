#Get latest linux AMI ID using SSM Parameter endpoint in us-east-1
data "aws_ssm_parameter" "east_ami" {
  provider = aws.useast1
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}
#Get latest linux AMI ID using SSM Parameter endpoint in us-west-2
data "aws_ssm_parameter" "west_ami" {
  provider = aws.uswest2
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}
resource "aws_instance" "east_instance" {
  provider      = aws.useast1
  ami           = data.aws_ssm_parameter.east_ami.value
  instance_type = var.instance_type

  tags = {
    Name = "Terraform-deploy1"
  }
}
resource "aws_instance" "west_instance" {
  provider      = aws.uswest2
  ami           = data.aws_ssm_parameter.west_ami.value
  instance_type = var.instance_type

  tags = {
    Name = "Terraform-deploy1"
  }
}