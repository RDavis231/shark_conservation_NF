# Creating DB Subnet Group
resource "aws_db_subnet_group" "db_subnet" {
  name       = "sharkblog-rds-subnetgroup"
  subnet_ids = [aws_subnet.private-1.id, aws_subnet.private-2.id]

  tags = {
    Name = "sharkblog-db-subnet"
  }
}

resource "aws_rds_cluster" "auroracluster" {
  cluster_identifier = "sharkblog-auroracluster"

  engine            = "aurora-mysql"
  engine_version    = "5.7.mysql_aurora.2.11.1"

  lifecycle {
    ignore_changes = [engine_version]
  }

  database_name       = "sharkblogdb"
  master_username     = "admin"
  master_password     = "wWkTAeM3n3ZQUlOBQzh0"

  skip_final_snapshot       = true
  final_snapshot_identifier = "sharkblog-aurora-final-snapshot"

  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.allow_aurora_access.id]

  tags = {
    Name = "sharkblog-auroracluster-db"
  }
}

resource "aws_rds_cluster_instance" "clusterinstance" {
  count               = 2
  identifier          = "sharkblog-clusterinstance-${count.index}"
  cluster_identifier  = aws_rds_cluster.auroracluster.id
  instance_class      = "db.t3.small"
  engine             = "aurora-mysql"
  availability_zone   = "us-east-1${count.index == 0 ? "a" : "b"}"
  publicly_accessible = true

  tags = {
    Name = "sharkblog-auroracluster-db-instance${count.index + 1}"
  }
}
