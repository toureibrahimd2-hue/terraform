output "aws_caller_identity" {
  value = data.aws_caller_identity.current.account_id
  
}



output "primary_instance_private_ip" {
  value = aws_instance.primary.private_ip
}

output "secondary_instance_private_ip" {
  value = aws_instance.secondary.private_ip
}

output "primary_instance_public_ip" {
  value = aws_instance.primary.public_ip
}

output "secondary_instance_public_ip" {
  value = aws_instance.secondary.public_ip
}