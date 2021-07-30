provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

module "label" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.13"
  name   = var.name
  tags   = var.tags
}

module "final_snapshot_label" {
  source = "github.com/mitlibraries/tf-mod-name?ref=0.13"
  name   = "${var.name}-final-snapshot"
  tags   = var.tags
}

resource "aws_db_instance" "default" {
  count                       = var.enabled == "true" ? 1 : 0
  identifier                  = module.label.name
  name                        = var.database_name
  username                    = var.database_user
  password                    = var.database_password
  port                        = var.database_port
  engine                      = var.engine
  engine_version              = var.engine_version
  instance_class              = var.instance_class
  allocated_storage           = var.allocated_storage
  storage_encrypted           = var.storage_encrypted
  vpc_security_group_ids      = [join("", aws_security_group.default.*.id)]
  db_subnet_group_name        = join("", aws_db_subnet_group.default.*.name)
  parameter_group_name        = length(var.parameter_group_name) > 0 ? var.parameter_group_name : join("", aws_db_parameter_group.default.*.name)
  option_group_name           = length(var.option_group_name) > 0 ? var.option_group_name : join("", aws_db_option_group.default.*.name)
  license_model               = var.license_model
  multi_az                    = var.multi_az
  storage_type                = var.storage_type
  iops                        = var.iops
  publicly_accessible         = var.publicly_accessible
  snapshot_identifier         = var.snapshot_identifier
  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  apply_immediately           = var.apply_immediately
  maintenance_window          = var.maintenance_window
  skip_final_snapshot         = var.skip_final_snapshot
  copy_tags_to_snapshot       = var.copy_tags_to_snapshot
  backup_retention_period     = var.backup_retention_period
  backup_window               = var.backup_window
  tags                        = module.label.tags
  final_snapshot_identifier   = length(var.final_snapshot_identifier) > 0 ? var.final_snapshot_identifier : module.final_snapshot_label.name
}

resource "aws_db_parameter_group" "default" {
  count  = length(var.parameter_group_name) == 0 && var.enabled == "true" ? 1 : 0
  name   = module.label.name
  family = var.db_parameter_group
  tags   = module.label.tags
  dynamic "parameter" {
    for_each = var.db_parameter
    content {
      apply_method = lookup(parameter.value, "apply_method", null)
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }
}

resource "aws_db_option_group" "default" {
  count                = length(var.option_group_name) == 0 && var.enabled == "true" ? 1 : 0
  name                 = module.label.name
  engine_name          = var.engine
  major_engine_version = var.major_engine_version
  tags                 = module.label.tags
  dynamic "option" {
    for_each = var.db_options
    content {
      db_security_group_memberships  = lookup(option.value, "db_security_group_memberships", null)
      option_name                    = option.value.option_name
      port                           = lookup(option.value, "port", null)
      version                        = lookup(option.value, "version", null)
      vpc_security_group_memberships = lookup(option.value, "vpc_security_group_memberships", null)

      dynamic "option_settings" {
        for_each = lookup(option.value, "option_settings", [])
        content {
          name  = option_settings.value.name
          value = option_settings.value.value
        }
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_subnet_group" "default" {
  count      = var.enabled == "true" ? 1 : 0
  name       = module.label.name
  subnet_ids = var.subnet_ids
  tags       = module.label.tags
}

resource "aws_security_group" "default" {
  count       = var.enabled == "true" ? 1 : 0
  name        = module.label.name
  description = "Allow inbound traffic from the security groups"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.database_port
    to_port         = var.database_port
    protocol        = "tcp"
    security_groups = var.security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = module.label.tags
}

resource "aws_route53_record" "default" {
  name    = module.label.name
  zone_id = var.dns_zone_id
  type    = "CNAME"
  ttl     = "300"
  records = aws_db_instance.default.*.address
  count   = var.enabled == "true" ? 1 : 0
}

