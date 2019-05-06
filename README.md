# VX-Labs Infrastructure

## Setup

This project uses https://github.com/poseidon/terraform-provider-ct to transpile ContainerLinux config into
JSON. It must be installed.

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

## TODO

* [x] Vault
* [ ] TLS
* [ ] ACL and Authz
* [ ] HA LB
* [ ] VPN private access
