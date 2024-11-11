#create a secret for Database
resource "random_password" "secret_password" {
  length  = 16
  special = true
}

resource "aws_secretsmanager_secret" "mongodb_password_secret" {
  name = "mongodb_password_secret"
}

resource "aws_secretsmanager_secret_version" "mongodb_password_secret_version" {
  secret_id     = aws_secretsmanager_secret.mongodb_password_secret.id
  secret_string = random_password.secret_password.result
}

resource "aws_secretsmanager_secret" "mongodb_username_secret" {
  name = "mongodb_username_secret"
}

resource "aws_secretsmanager_secret_version" "mongodb_username_secret_version" {
  secret_id     = aws_secretsmanager_secret.mongodb_username_secret.id
  secret_string = var.db_username
}

resource "aws_docdb_cluster_parameter_group" "mongo-custom-parameter-group" {
  family      = "docdb5.0"
  name        = "mongodb-custom-parameter-group"
  description = "docdb cluster parameter group"

  parameter {
    name  = "tls"
    value = "disabled"
  }
}
resource "aws_docdb_subnet_group" "mongo_subnet_group" {
  name       = "mongodb-subnet-group"
  subnet_ids = db_subnets

  tags = {
    Name = "My docdb subnet group"
  }
}
resource "aws_docdb_cluster" "mongodb_cluster" {
  cluster_identifier      = "udemy-mongodb-cluster"
  engine                  = "docdb"
  master_username         = var.db_username
  master_password         = aws_secretsmanager_secret_version.mongodb_password_secret_version.secret_string
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.mongo-custom-parameter-group.name
  vpc_security_group_ids = var.db_security_group_ids
  db_subnet_group_name = aws_docdb_subnet_group.mongo_subnet_group.name
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = 1
  identifier         = "udemy-mongodb-cluster-${count.index}"
  cluster_identifier = aws_docdb_cluster.mongodb_cluster.id
  instance_class     = "db.t3.medium"
}
