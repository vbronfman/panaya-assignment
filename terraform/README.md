# Deployment to AWS ECS 

The project is stripped down solution https://github.com/vbronfman/tf-ecs-fargate-tmpl originated from Andreas Jantschnig (andreas.jantschnig@finleap.com) 
The solution creates ECS cluster, dploys service with two tasks and ALB.

Images are stored at Docker Hub
Requires IAM user with permissions to create roles.

## Usage:
terraform init
terraform plan
terraform apply --auto-approve -var aws-access-key=xxxxx -var aws-secret-key=xxxxx -var name=<somename>


### References
 https://engineering.finleap.com/posts/2020-02-20-ecs-fargate-terraform/ 
 https://nexgeneerz.io/how-to-setup-amazon-ecs-fargate-terraform/ 
