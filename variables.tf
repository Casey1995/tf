variable "profile" {
  type    = string
  default = "default"
}
variable "useast1" {
  type    = string
  default = "us-east-1"
}
variable "uswest2" {
  type    = string
  default = "us-west-2"
}
variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}
variable "instance_type" {
  type = string
  default = "t2.micro"  
}