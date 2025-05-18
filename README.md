# ecs-self-signed

IaC project that encrypts traffic between load balancer and ECS tasks using self-signed certificates and side-car container 
=====================================
Command to import cert:
aws acm import-certificate \
--certificate fileb://my-aws-public.crt \
--private-key fileb://my-aws-private.key \
--certificate-chain  fileb://castore.pem \
--region eu-west-2


pre-requisites:
- aws account
- terraform cloud account
- registered domain:


test:
sudo tcpdump -i enX0 -nn -vv -A host <ecs_task_ip>



Why not to register domain as part of TF project:
    - Keeps Terraform focused on infrastructure, not ownership tasks.
    - Domain names are typically long-lived and cross-project (used by many services or apps).
    - Easier to handle things like WHOIS privacy, domain locking, multi-year renewals manually.