# VX-Labs Infrastructure

## Usage

Building instance images:

```
cd images
cp env-example .env
vim .env
docker-compose up
```

Spawning the infrastructure
```
cp secrets-example secrets
vim secrets
. ./secrets
terraform apply
```
