output "aws_vpc_id" {
  value = aws_vpc.myvpc.id
}

output "pub_ip" {
  value = aws_instance.my_vm.public_ip
}