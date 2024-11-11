## Bộ terraform template này sẽ tạo ra full resource trên AWS bao gồm:
- Networking, VPC, Subnet, Security Group.
- Application Load Balancer, TargetGroup, Listener
- Ecs Cluster
- ECS Service FE
- ECS Service BE
- Document DB - MongoEngine
- SecretManager chứa username, password của MongoDB.

### Commands Terraform:
```cd singapore-dev```
#### Chỉnh sửa file sau: singapore-dev/terraform.tfvars
- Dòng 6: ```frontend_ecr_repo_url``` ->chỉnh sửa thành url ECR repository của bạn ví dụ:
```430950558682.dkr.ecr.ap-southeast-1.amazonaws.com/nodejs-random-color:ver-2```
- Dòng 7: backend_ecr_repo_url ->chỉnh sửa thành url ECR repository của bạn ví dụ:
```430950558682.dkr.ecr.ap-southeast-1.amazonaws.com/nodejs-random-color:ver-2```
- Dòng 8: ```mongodb_username``` ->chỉnh sửa thành username của bạn vd:
```linhadmin```
- Dòng 9: ```mongodb_password``` ->chỉnh sửa thành username của bạn vd: ```123456789``` (!Lưu ý không commit password lên Git)


#### Chạy lệnh sau:
- ```terraform init```
- ```terraform plan --var-file "terraform.tfvars"```
- ```terraform apply --var-file "terraform.tfvars"```

#### Kiểm tra các resource được tạo ra & thử truy cập ALB.
