output "mongodb_username_secret_arn" {
  value = aws_secretsmanager_secret.mongodb_username_secret.arn
}
output "mongodb_password_secret_arn" {
  value = aws_secretsmanager_secret.mongodb_password_secret.arn
}
output "mongodb_endpoint"{
  value = aws_docdb_cluster.mongodb_cluster.endpoint
}