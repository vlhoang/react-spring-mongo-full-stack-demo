# kubernetes-full-stack-example
## Trước khi các bạn thực hiện bất cứ step nào khác, đảm bảo project có thể run bởi docker-compose
- ```docker-compose -f docker-compose.yaml up -d```
- Sau đó truy cập vào localhost:80 để xem website. Thử add một vài user, view list users.

## Giải thích về file cấu trúc project
### Frontend
- Nodejs project có nhiệm vụ list, add, delete users.
- Dockercompose file build ra static image chạy trên nginx.
- Docker image nhận biến môi trường: baseURL là url của API Backend.
### Backend
- Java Spring boot có nhiệm vụ cung cấp API list, add, delete users.
- Dockercompose file build ra static image chạy trên Java OpenJDK.
- Docker image nhận biến môi trường: MONGO_URL là url của MongoDB.
### Database
- Sử dụng image sẵn có của Mongo.

### Yêu cầu của assignment: Triển khai lên AWS & cấu hình CICD theo 1 trong 2 phương án sau:
### Lưu ý: riêng phần CICD, có thể triển khai mono repo hoặc tách frontend, backend thành 2 repo.
### Phương án 1:
- Frontend: S3 + CloudFront.
- Backend: ECS, ECR.
- Database: Document DB.
- Load Balance: ALB
- CICD: Jenkins, GithubAction hoặc CodePipeline đều được.
- Chiến lược deploy cho backend: Rolling update hoặc Blue-Green.

### Phương án 2:
- Frontend: Serverside Rendering trên EKS
- Backend: EKS, ECR.
- Database: Document DB.
- Load Balance: ALB
- CICD: Jenkins, GithubAction hoặc CodePipeline đều được.
- Chiến lược deploy cho backend: Rolling update hoặc Blue-Green.

### Phương án gợi ý:
#### ⁠Lựa chọn 1 trong 2 kiến trúc phù hợp: 

- Phương án 1: Frontend: S3+CloudFront, Backend: ECS, DB: Document DB chạy Mongo, kết hợp ALB.
- Phương án 2: Frontend & Backend đều triển khai lên ECS, DB: Document DB chạy Mongo, kết hợp ALB.
### Step thực hiện:
#### 1. Tạo network (VPC, Subnet), security group & ECS Cluster, ECR repo cho FE, BE để triển khai ứng dụng.
#### 2. Tạo Document DB (Mongo Engine)
#### 3. ⁠Triển khai Backend
- Build Dockerimage và push lên ECR. 
- Tạo Backend service, lưu ý overwrite MONGO_URL cho backend. 
- Cấu hình ALB với listener /api/* trỏ vào backend service. 
- Test API vd GET <domain-alb>:80/api/students
#### 4. Triển khai Frontend
- Build Frontend tạo ra static website & push lên S3 (nếu sd phương án 1) *lưu ý cấu hình môi trường baseURL khi build để nhận backend URL.
- Cấu hình CloudFront cho Frontend.
- Test truy cập tới Frontend thông qua CloudFront URL.
- Build Frontend tạo ra Docker image, push lên ECR (nếu sd phương án 2).
- Tạo Frontend Service, lưu ý overwrite baseURL để frontend nhận diện được backend API. Tạo thêm listener trên ALB /* trỏ tới Frontend (lưu ý thứ tự ưu tiên /api/* phải nằm trên /*).
#### 5. Test kết nối tới ALB & truy cập ứng dụng.

## Chúc các bạn deploy thành công!
