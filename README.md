# ecs-self-signed

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