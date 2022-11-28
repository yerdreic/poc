# poc

## Description

> "Applications must sign their API requests with AWS credentials. Therefore,
if you are an application developer, you need a strategy for managing
credentials for your applications that run on EC2 instances. For example, you
can securely distribute your AWS credentials to the instances, enabling the
applications on those instances to use your credentials to sign requests,
while protecting your credentials from other users. However, it's
challenging to securely distribute credentials to each instance, especially
those that AWS creates on your behalf, such as Spot Instances or instances in
Auto Scaling groups. You must also be able to update the credentials on each
instance when you rotate your AWS credentials."
</br>-- [AWS Documentation][1]

A POC for running an "application" on AWS EC2 while consuming (reading) secrets from
AWS secrets manager (SM) using IAM Roles instead of creds distribution

## Arcitecture

- A secret generated and tracked in SM
- IAM Role for EC2 - with a policy to read secrets from SM
- An EC2 instance with an assosicated IAM Role
- Consumer container ("application")- running in the EC2 instance which
  consumes the secret

## local DEV Environment

### pre-commit

To run pre-commit locally, follow the instructions:

```shell
pip install --user pre-commit
pre-commit install
```

### Dependencies update

[Renovate][2] takes care of it

### Building consumer image

```shell
make build
```

### Running consumer container

```shell
make run
```

### Viewing consumer container logs

```shell
make logs
```

### Stopping and removing consumer container

```shell
make rm
```

[1]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html
[2]: https://github.com/renovatebot/renovate

## PROD environment

### System Requirements

- `make`
- `ansible`
- `terraform`
- `awscli`

### Infra bootstrapping

```shell
make infra-format
make infra-plan
make infra-apply
```

### Provisioning

```shell
make provision
```
