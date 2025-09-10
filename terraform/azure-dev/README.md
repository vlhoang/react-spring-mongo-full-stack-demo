# Triển khai Azure (Container Apps + Cosmos + Front Door)

Stack này triển khai dự án lên Azure gồm:
- Azure Resource Group
- Azure Cosmos DB for MongoDB (bật TLS)
- Azure Container Registry (ACR)
- Azure Container Apps Environment và Container App Backend (public ingress cổng 8080)
- Azure Storage Static Website (host build React)
- Azure Front Door (Standard) định tuyến:
  - `/api/*` → Container App Backend
  - `/*` → Static Website

## Yêu cầu chuẩn bị
- Terraform >= 1.5.0
- Azure CLI đã đăng nhập (`az login`)
- Ảnh container backend đã được build và push lên ACR (hoặc dùng CI để push)

## Biến đầu vào (variables)
Cung cấp qua tfvars hoặc `-var`.
- `location` (string): Vùng Azure, ví dụ `southeastasia`
- `resource_group_name` (string)
- `cosmos_account_name` (string): duy nhất toàn cầu
- `cosmos_database_name` (string): mặc định `dev`
- `acr_name` (string): duy nhất toàn cầu
- `acr_sku` (string): `Basic|Standard|Premium` (mặc định: `Basic`)
- `log_analytics_name` (string)
- `containerapps_env_name` (string)
- `backend_app_name` (string)
- `backend_image` (string): ví dụ `<acr>.azurecr.io/backend:latest`
- `static_site_account_name` (string): tên storage account (duy nhất)
- `frontdoor_profile_name` (string)
- `frontdoor_endpoint_name` (string)

## Ví dụ tfvars (dev.tfvars)
```hcl
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
```

## Triển khai
```bash
cd terraform/azure-dev
terraform init
terraform apply -var-file=dev.tfvars
```

## Outputs
- `cosmos_mongo_connection_string`: URI dùng làm `MONGO_URL` (đã có tham số TLS)
- `acr_login_server`, `acr_admin_username`: phục vụ CI/CD
- `backend_fqdn`: FQDN public của Container App
- `static_site_endpoint`: Endpoint của static website
- `frontdoor_hostname`: Hostname public phục vụ FE và BE

## Sau triển khai
- Frontend `.env` đặt `REACT_APP_API_URL=https://<frontdoor_hostname>/api`
- Build frontend:
  ```bash
  cd react-student-management
  npm ci
  npm run build
  ```
- Upload thư mục `build/` lên Storage Static Website (container `$web`) bằng Portal hoặc az CLI:
  ```bash
  az storage blob upload-batch \
    --account-name <static_site_account_name> \
    --destination "$web" \
    --source build \
    --auth-mode login
  ```
- Truy cập ứng dụng tại `https://<frontdoor_hostname>`

## Ghi chú
- Spring Boot đã đọc `spring.data.mongodb.uri` từ `MONGO_URL`; không cần sửa code để dùng Cosmos TLS.
- Health probe backend là `GET /api/students`.
- Ưu tiên dùng CI để build/push image lên ACR và deploy Container App; lưu secrets trong GitHub Secrets hoặc Azure Key Vault.


