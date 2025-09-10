React + Spring Boot + Mongo trên Azure (Container Apps, Cosmos DB, Front Door)

Tổng quan
- Mục đích: Triển khai stack demo này lên Azure bằng các dịch vụ tương đương với thiết kế trên AWS trong README.md.
- Tính năng: Liệt kê/thêm/xóa người dùng.
- Stack:
  - Frontend: React (Node 20) cổng 3000 (dùng REACT_APP_API_URL)
  - Backend: Spring Boot REST API cổng 8080 (dùng MONGO_URL)
  - Database: Azure Cosmos DB for MongoDB (bật TLS)

Chạy local (không đổi)
- docker-compose -f docker-compose.yaml up -d
- Mở http://localhost:3000 và thử thêm vài user

Ánh xạ dịch vụ Azure
- ECR → Azure Container Registry (ACR)
- ECS (Fargate) → Azure Container Apps (ACA)
- ALB → Azure Front Door (Standard)
- S3 + CloudFront → Azure Storage Static Website + Azure Front Door
- DocumentDB (Mongo) → Azure Cosmos DB for MongoDB
- Secrets Manager → Azure Key Vault (tùy chọn cho demo này)
- CI/CD: GitHub Actions hoặc Azure DevOps

Phương án 1: FE và BE đều đi qua Front Door
- Hạ tầng
  - Cosmos DB for MongoDB (vCore hoặc API for MongoDB)
  - ACR (container registry)
  - Container Apps Environment
  - Container App: backend (public ingress, target port 8080)
  - Storage Account bật Static Website để host build frontend
  - Front Door (Standard):
    - Route /api/* → Container App backend
    - Route /* → Static Website
- Cấu hình
  - Backend MONGO_URL = chuỗi kết nối Mongo của Cosmos (có ssl/tls và retryWrites=false)
  - Frontend REACT_APP_API_URL = https://<frontdoor-hostname>/api
- CI/CD
  - Build/push image backend lên ACR; cập nhật image cho Container App
  - Build React → upload thư mục build/ lên Storage $web; có thể purge cache Front Door

Phương án 2: Bắt đầu đơn giản chỉ với Backend trên Container Apps
- Dùng FQDN public của Container App để test API
- Frontend vẫn có thể host trên Static Website; thêm Front Door sau để gom về một URL

Chuỗi kết nối Cosmos DB (quan trọng)
- Dùng chuỗi kết nối Azure cung cấp và truyền vào app qua MONGO_URL, ví dụ:
  - mongodb://<user>:<password>@<account>.mongo.cosmos.azure.com:10255/dev?ssl=true&retrywrites=false
  - hoặc dạng SRV: mongodb+srv://<user>:<password>@<cluster>.mongo.cosmos.azure.com/dev?tls=true&retrywrites=false
- Spring Boot đọc spring.data.mongodb.uri từ MONGO_URL; không cần sửa code.

Terraform (azure-dev)
- Vị trí: terraform/azure-dev
- Triển khai:
  - Resource Group
  - Cosmos DB (Mongo) + database
  - ACR
  - Container Apps Environment + Container App Backend
  - Storage Static Website
  - Front Door (route: /api/* → backend, /* → static)
- Ví dụ tfvars:
  location               = "southeastasia"
  resource_group_name    = "rg-student-app-dev"
  cosmos_account_name    = "cosmosstudentdev123"
  cosmos_database_name   = "dev"
  acr_name               = "studentacrdev123"
  acr_sku                = "Basic"
  log_analytics_name     = "log-student-dev"
  containerapps_env_name = "cae-student-dev"
  backend_app_name       = "student-backend"
  backend_image          = "studentacrdev123.azurecr.io/backend:latest"
  static_site_account_name = "studentstaticdev123"
  frontdoor_profile_name  = "fdp-student-dev"
  frontdoor_endpoint_name = "fde-student-dev"

Triển khai với Terraform
- az login
- cd terraform/azure-dev
- terraform init
- terraform apply -var-file=dev.tfvars

Outputs (chính)
- cosmos_mongo_connection_string: Dùng làm MONGO_URL nếu chạy ở nơi khác
- acr_login_server, acr_admin_username: Cho CI đăng nhập
- backend_fqdn: FQDN public của Container App backend
- static_site_endpoint: URL của static website
- frontdoor_hostname: Hostname public phục vụ cả FE và BE

Build và upload Frontend
- Đặt REACT_APP_API_URL=https://<frontdoor_hostname>/api trong react-student-management/.env
- Build:
  - cd react-student-management
  - npm ci
  - npm run build
- Upload thư mục build/ lên Storage Static Website (container $web):
  - az storage blob upload-batch --account-name <static_site_account_name> --destination "$web" --source build --auth-mode login

Kiểm thử
- Mở https://<frontdoor_hostname>
- Thử thêm/xóa user
- Test API: https://<frontdoor_hostname>/api/students (GET)

CI/CD (khuyến nghị)
- GitHub Actions (2 workflow):
  1) Backend: chạy khi push vào develop
     - docker login vào ACR
     - build/push image backend
     - cập nhật image cho Container App
  2) Frontend: chạy khi push vào develop
     - npm ci && npm run build
     - upload build/ lên Storage $web
     - tùy chọn: purge cache Front Door

Bảo mật & ghi chú
- Lưu thông tin ACR và cloud vào GitHub Secrets; cân nhắc Azure Key Vault cho secrets runtime
- Cosmos DB yêu cầu TLS; không tắt
- Ưu tiên dùng Front Door thay vì URL trực tiếp của Container App cho môi trường người dùng
