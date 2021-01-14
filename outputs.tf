#syntax to output resource metadata
output "master_vpc_id" {
  value = aws_vpc.master_vpc.id
}

#syntax to output resource metadata
output "east_server_public_ip" {
  value = aws_instance.east_instance.public_ip
}
#syntax to output resource metadata
output "west_server_public_ip" {
  value = aws_instance.west_instance.public_ip
}