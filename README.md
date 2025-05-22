# ecs-self-signed

IaC project that encrypts traffic between a load balancer and ECS tasks using self-signed certificates and a sidecar container.

---

## Prerequisites

- AWS account  
- Terraform Cloud account  
- Registered domain  

---

## How to Deploy

1. **Deploy infrastructure**  
   Run `terraform apply` locally or via the `infrastructure-deploy.yaml` pipeline.

2. **Generate and upload self-signed certificate**  
   - Generate a self-signed certificate  
   - Import it to ACM  
   - Upload it to the S3 bucket `aws_s3_bucket.utils`  
   You can use the `create-rsa-cert.yaml` pipeline to automate this.

3. **Build and push Docker images**  
   Build and push Docker images to the following ECR repositories:
   - `aws_ecr_repository.app_repo`
   - `aws_ecr_repository.envoy_repo`  
   See the `upload-docker-images.yaml` pipeline.

---

## How to Verify Traffic is Encrypted

1. Deploy all resources in `./tests`
2. Use **SSM Session Manager** to connect to the traffic mirror target EC2 instance
3. Run the following command:
   ```bash
   sudo tcpdump -i enX0 -nn -vv -A host <ecs_task_ip>
4. Stop the command and verify that all packets are encrypted

---

## How to Generate a Self-Signed Certificate Using OpenSSL

1. **Generate a 2048-bit private key for the Certificate Authority (CA):**

   ```bash
   openssl genrsa -out castore.key 2048

2. **Create a self-signed certificate:**

   ```bash
   openssl req -x509 -new -nodes -key castore.key -days 3650 -config castore.cfg -out castore.pem

3. **Generate a  private key for your ECS app:**

   ```bash
   openssl genrsa -out my-aws-private.key 2048

4. **Generate a CSR:**

   ```bash
   openssl req -new -key my-aws-private.key -out my-aws.csr -config castore.cfg
    The CSR (my-aws.csr) is what you'll send to a CA to be signed.

5. **Use the CA to sign the CSR and issue a certificate:**

   ```bash
   openssl x509 -req -in my-aws.csr -CA castore.pem -CAkey castore.key -CAcreateserial  -out my-aws-public.crt -days 365
    The resulting file, my-aws-public.crt, is the public certificate for your service, valid for 1 year. The command also generates a castore.srl file (serial number for tracking issued certs).
