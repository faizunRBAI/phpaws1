# phpaws1

A PHP 8.2 / Laravel 11 web application deployed on AWS EC2, provisioned with Terraform and configured with Ansible through a GitHub Actions CI/CD pipeline.

## Architecture

- **App**: Laravel 11 on PHP 8.2-FPM, served via Nginx
- **Host**: AWS EC2 t3.micro (Ubuntu 22.04 LTS) with Elastic IP
- **IaC**: Terraform (infra/) — EC2, EIP, Security Group, Key Pair
- **Config**: Ansible (ansible/site.yml) — PHP, Composer, Nginx, Laravel setup
- **CI/CD**: GitHub Actions (lint → test → provision → configure → verify)

See `.udap/architecture.d2` for the architecture diagram.

## Local Development

### Prerequisites
- PHP 8.2+
- Composer

### Run locally

```bash
# Install dependencies
composer install

# Copy and configure environment
cp .env.example .env
php artisan key:generate

# Start the development server
php artisan serve
```

The application will be available at `http://localhost:8000`.

### Run tests

```bash
./vendor/bin/phpunit --testdox
```

## Deployment

Deployment is fully automated via GitHub Actions on push to `main`.

### Pipeline stages

| Stage       | Description                                          |
|-------------|------------------------------------------------------|
| `lint`      | PHP syntax check across all source files             |
| `test`      | PHPUnit feature/unit tests                           |
| `provision` | Terraform: EC2, EIP, Security Group, Key Pair        |
| `configure` | Ansible: PHP-FPM, Nginx, Laravel app setup           |
| `verify`    | HTTP health check against the live EC2 Elastic IP    |

## Configuration

All secrets are managed via GitHub Actions secrets (set by the UDAP platform):

| Secret               | Description                              |
|----------------------|------------------------------------------|
| `AWS_ACCESS_KEY_ID`  | AWS credentials (set by platform)        |
| `AWS_SECRET_ACCESS_KEY` | AWS credentials (set by platform)     |
| `TF_STATE_BUCKET`    | Terraform state S3 bucket (set by platform) |
| `PROJECT_NAME`       | Branch-scoped project name (set by platform) |
| `SSH_PUBLIC_KEY`     | EC2 SSH public key (set by platform)     |
| `SSH_PRIVATE_KEY`    | EC2 SSH private key (set by platform)    |
| `SSH_USER`           | EC2 SSH user — `ubuntu` (set by platform) |

## Operations

### View app URL

After the first successful deploy, the EC2 Elastic IP is available as a Terraform output:

```bash
cd infra
terraform output app_url
```

The app URL is available at `http://<elastic-ip>` (set after first deploy).

### SSH into the server

```bash
ssh -i ~/.ssh/deploy_key ubuntu@<elastic-ip>
```

### View application logs

```bash
sudo journalctl -u nginx -f
sudo tail -f /var/www/phpaws1/storage/logs/laravel.log
```

### Restart services

```bash
sudo systemctl restart nginx
sudo systemctl restart php8.2-fpm
```

### Destroy infrastructure

Trigger the **Destroy** workflow from the GitHub Actions tab in the repository to tear down all AWS resources.
