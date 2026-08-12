# phpaws1 — Build Notes

## Project decisions
- PHP 8.2 / Laravel 11 scaffolded via platform scaffold (laravel template)
- AWS EC2 t3.micro, Ubuntu 22.04, us-east-1
- Single instance + EIP (Tier 1 — no load balancer, no RDS)
- Nginx as reverse proxy → PHP-FPM socket (port 80)
- No database at this tier — using SQLite in /tmp for session/cache if needed
- Ondrej PHP PPA used on Ubuntu to get PHP 8.2 (Ubuntu 22.04 base has 8.1 only)
- composer install uses --no-dev on the host (production), full deps in CI for tests
- phpunit/phpunit + nunomaduro/collision in require-dev for `php artisan test` and `./vendor/bin/phpunit`
- bootstrap/cache/.gitkeep shipped by scaffold — avoids package:discover abort

## Status
- [ ] Scaffold done
- [ ] Terraform written
- [ ] Ansible written
- [ ] README written
- [ ] validate_project passed
- [ ] test_project passed
- [ ] Repo pushed
- [ ] Deployed

## Known gotchas
- Ubuntu 22.04 apt has PHP 8.1 by default → must add ondrej/php PPA before installing php8.2-*
- EIP output used as ec2_public_ip everywhere (not the ephemeral instance IP)
- PROJECT_NAME is a masked secret → never used in terraform output names that get threaded as job outputs
- configure/verify stages re-init terraform from state to get the EIP — self-sufficient job rule
