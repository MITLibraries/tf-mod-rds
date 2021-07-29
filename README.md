# tf-mod-rds

Terraform module to provision AWS RDS instances.

This module is originally from [Cloudposse's RDS module](https://github.com/cloudposse/terraform-aws-rds). For production usage, an RDS read replica should be created.

## MySQL Example:
 ```
module "db" {
  source                      = "github.com/mitlibraries/tf-mod-rds?ref=0.13"
  engine                      = "mysql"
  engine_version              = "5.7.34"
  instance_class              = "db.t3.micro"
  allocated_storage           = 20
  name                        = "appname-rds" # ONLY alphanumeric characters and hypen!
  database_name               = "dbname"      # ONLY alphnumeric characters!
  database_user               = var.rds_username
  database_password           = var.rds_password
  database_port               = "3306"
  db_parameter_group          = "mysql5.7"
  maintenance_window          = "Sun:00:00-Sun:03:00"
  backup_window               = "03:00-06:00"
  vpc_id                      = module.shared.vpc_id
  subnet_ids                  = module.shared.private_subnets
  security_group_ids          = [aws_security_group.default.id]
  major_engine_version        = "5.7"
  allow_major_version_upgrade = "false"
  apply_immediately           = "true"
  dns_zone_id                 = module.shared.private_zoneid
}
```

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| final\_snapshot\_label | github.com/mitlibraries/tf-mod-name | 0.13 |
| label | github.com/mitlibraries/tf-mod-name | 0.13 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allocated\_storage | The allocated storage in GBs | `string` | n/a | yes |
| allow\_major\_version\_upgrade | Allow major version upgrade | `string` | `"false"` | no |
| apply\_immediately | Specifies whether any database modifications are applied immediately, or during the next maintenance window | `string` | `"false"` | no |
| auto\_minor\_version\_upgrade | Allow automated minor version upgrade (e.g. from Postgres 9.5.3 to Postgres 9.5.4) | `string` | `"true"` | no |
| backup\_retention\_period | Backup retention period in days. Must be > 0 to enable backups | `string` | `0` | no |
| backup\_window | When AWS can perform DB snapshots, can't overlap with maintenance window | `string` | `"22:00-03:00"` | no |
| copy\_tags\_to\_snapshot | Copy tags from DB to a snapshot | `string` | `"true"` | no |
| database\_name | The name of the database to create when the DB instance is created | `string` | n/a | yes |
| database\_password | (Required unless a snapshot\_identifier or replicate\_source\_db is provided) Password for the master DB user | `string` | `""` | no |
| database\_port | Database port (\_e.g.\_ `3306` for `MySQL`). Used in the DB Security Group to allow access to the DB instance from the provided `security_group_ids` | `string` | n/a | yes |
| database\_user | (Required unless a `snapshot_identifier` or `replicate_source_db` is provided) Username for the master DB user | `string` | `""` | no |
| db\_options | A list of DB options to apply with an option group.  Depends on DB engine | ```list(object({ db_security_group_memberships = list(string) option_name = string port = number version = string vpc_security_group_memberships = list(string) option_settings = list(object({ name = string value = string })) }))``` | `[]` | no |
| db\_parameter | A list of DB parameters to apply. Note that parameters may differ from a DB family to another | ```list(object({ apply_method = string name = string value = string }))``` | `[]` | no |
| db\_parameter\_group | Parameter group, depends on DB engine used | `string` | n/a | yes |
| dns\_zone\_id | The ID of the DNS Zone in Route53 where a new DNS record will be created for the DB host name | `string` | `""` | no |
| enabled | Set to false to prevent the module from creating any resources | `string` | `"true"` | no |
| engine | Database engine type | `string` | n/a | yes |
| engine\_version | Database engine version, depends on engine type | `string` | n/a | yes |
| final\_snapshot\_identifier | Final snapshot identifier e.g.: some-db-final-snapshot-2015-06-26-06-05 | `string` | `""` | no |
| host\_name | The DB host name created in Route53 | `string` | `"db"` | no |
| instance\_class | Class of RDS instance | `string` | n/a | yes |
| iops | The amount of provisioned IOPS. Setting this implies a storage\_type of 'io1'. Default is 0 if rds storage type is not 'io1' | `string` | `"0"` | no |
| license\_model | License model for this DB.  Optional, but required for some DB Engines. Valid values: license-included \| bring-your-own-license \| general-public-license | `string` | `""` | no |
| maintenance\_window | The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi' UTC | `string` | `"Mon:03:00-Mon:04:00"` | no |
| major\_engine\_version | Database MAJOR engine version, depends on engine type | `string` | `""` | no |
| multi\_az | Set to true if multi AZ deployment must be supported | `string` | `"false"` | no |
| name | The Name of the application or solution  (e.g. `bastion` or `portal`) | `string` | n/a | yes |
| option\_group\_name | Name of the DB option group to associate | `string` | `""` | no |
| parameter\_group\_name | Name of the DB parameter group to associate | `string` | `""` | no |
| publicly\_accessible | Determines if database can be publicly available (NOT recommended) | `string` | `"false"` | no |
| security\_group\_ids | he IDs of the security groups from which to allow `ingress` traffic to the DB instance | `list(string)` | `[]` | no |
| skip\_final\_snapshot | If true (default), no snapshot will be made before deleting DB | `string` | `"true"` | no |
| snapshot\_identifier | Snapshot identifier e.g: rds:production-2015-06-26-06-05. If specified, the module create cluster from the snapshot | `string` | `""` | no |
| storage\_encrypted | (Optional) Specifies whether the DB instance is encrypted. The default is false if not specified. | `string` | `"false"` | no |
| storage\_type | One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD). | `string` | `"standard"` | no |
| subnet\_ids | List of subnets for the DB | `list(string)` | n/a | yes |
| tags | Additional tags (e.g. map(`BusinessUnit`,`XYZ`) | `map(string)` | `{}` | no |
| vpc\_id | VPC ID the DB instance will be created in | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| hostname | DNS host name of the instance |
| instance\_address | Address of the instance |
| instance\_endpoint | DNS Endpoint of the instance |
| instance\_id | ID of the instance |
| option\_group\_id | ID of the Option Group |
| parameter\_group\_id | ID of the Parameter Group |
| security\_group\_id | ID of the Security Group |
| subnet\_group\_id | ID of the Subnet Group |
