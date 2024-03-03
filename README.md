# ecs-self-signed

IaC project that encrypts traffic between load balancer and ECS tasks using self-signed certificates and side-car container 
=====================================
Command to import cert:
aws acm import-certificate \
--certificate fileb://my-aws-public.crt \
--private-key fileb://my-aws-private.key \
--certificate-chain  fileb://castore.pem \
--region eu-west-2
