output "subnet_ids" {
  value = { for k, v in aws_subnet.this : k => v.id }
}
