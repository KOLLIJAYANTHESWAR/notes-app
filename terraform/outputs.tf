output "instance_public_ip" {
  value       = aws_instance.notes_instance.public_ip
  description = "Public IP of the Notes App EC2 instance"
}
