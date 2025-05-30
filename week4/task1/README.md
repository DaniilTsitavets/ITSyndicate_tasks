## Task 1 Deploy and Configure Infrastructure Using Terraform and Ansible

### Overview
- Provisioning network infrastructure and EC2 instances via Terraform
- Installing and configuring PostgreSQL database on a dedicated instance
- Setting up two application servers with necessary software and Nginx as a reverse proxy
- Deploying the Django app with environment configuration and database migrations using Ansible
- Load balancing incoming traffic with an AWS Application Load Balancer
- Using AWS SSM Agent to manage instances remotely without SSH
- Generating a dynamic Ansible inventory file from Terraform outputs

### Infrastructure Provisioning with Terraform

Terraform scripts are located in the `terraform/` directory, divided into files for:

- VPC, subnets, nat gateway, routing tables, and security groups (`vpc.tf`)
- EC2 instance creation (`ec2.tf`)
- IAM roles and policies including SSM access (`iam.tf`)
- Application Load Balancer setup (`alb.tf`)
- Outputs and dynamic inventory generation (`outputs.tf`)
- Variables (`variables.tf`)
- Template for hosts file generation (`inventory.tpl` + `main.tf`)

#### Key Terraform Features

- Created a VPC with public and private subnets
- Launched 3 EC2 instances in private subnets: 2 for Django app, 1 for PostgreSQL
- Attached IAM roles for SSM Session Manager access
- Configured Application Load Balancer to distribute traffic on port 80 to app instances
- Generated an Ansible inventory file dynamically via Terraform output

### Configuration Management with Ansible

Ansible playbooks and roles are organized in the `ansible/` directory:

#### Roles

- **postgres-setup**
    - Installs PostgreSQL server
    - Creates database and user
    - Configures PostgreSQL for network access

- **webserver-setup**
    - Installs Python, Gunicorn, Nginx, and dependencies
    - Configures Nginx as reverse proxy to Gunicorn on port 8000

- **deploy**
    - Clones Django app from GitHub
    - Creates `.env` with DB credentials
    - Runs Django migrations
    - Restarts Gunicorn service

#### Playbooks

- `db.yml` - runs `postgres-setup` role on DB instance
- `webservers.yml` - runs `webserver-setup` role on app instances
- `deploy.yml` - runs `deploy` role on app instances

### Integration with AWS SSM

- Ansible connects to instances via AWS SSM Session Manager (`ansible_connection: aws_ssm`)
- No SSH needed; uses IAM roles for secure access
