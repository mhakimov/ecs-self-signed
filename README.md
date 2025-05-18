# ecs-self-signed

IaC project that encrypts traffic between load balancer and ECS tasks using self-signed certificates and side-car container 
=====================================

Pre-requisites:
- aws account
- terraform cloud account
- registered domain

How to deploy:
Step 1: Deploy infrastructure by running `terraform apply` locally or via infrastructure-deploy.yaml pipeline.
Step 2: Genereate self-signed certificate, import it to ACM, and upload it to the aws_s3_bucket.utils bucket. You can use create-rsa-cert.yaml pipeline to do it.
Step 3: Build and push docker image to the ECR repositories aws_ecr_repository.app_repo and aws_ecr_repository.envoy_repo. See upload-docker-images.yaml

How to verify traffic is encrypted:
Step 1: Deploy all resources in ./tests
Step 2: SSM connect into the traffic mirror target EC2
Step 3: Run `sudo tcpdump -i enX0 -nn -vv -A host <ecs_task_ip>`
Step 4: Stop the command and verify that all packets are encrypted


How to generate self-signed certificate using openssl:
Step 1: Generate a 2048-bit private key for the Certificate Authority (CA)
    `openssl genrsa -out castore.key 2048`

Step 2: Create a self-signed certificate:
    `openssl req -x509 -new -nodes -key castore.key -days 3650 -config castore.cfg -out castore.pem`
    This makes castore.pem a trusted root certificate. Now you have a root CA: castore.pem (cert) + castore.key (private key)

Step 3: Generate a  private key for your ECS app:
    `openssl genrsa -out my-aws-private.key 2048`

Step 4: Generate a CSR:
    `openssl req -new -key my-aws-private.key -out my-aws.csr -config castore.cfg`
    The CSR (my-aws.csr) is what you'll send to a CA to be signed.

Step 5: Use the CA to sign the CSR and issue a certificate
    `openssl x509 -req -in my-aws.csr -CA castore.pem -CAkey castore.key -CAcreateserial  -out my-aws-public.crt -days 365`
    The resulting file, my-aws-public.crt, is the public certificate for your service, valid for 1 year. The command also generates a castore.srl file (serial number for tracking issued certs).
