output "instance_id" {
  value = aws_instance.nat_instance.id
}

output "public_ip" {
  value       = aws_instance.nat_instance.public_ip
  description = "The public IP of the web server"
}

output "key_pair_id" {
  value = aws_key_pair.generated_key.key_pair_id
  description = "The public key id"
}

output "security_group" {
  value = aws_security_group.nat_sg.id
}