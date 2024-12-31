# CICD sử dụng Jenkins (hướng dẫn dành cho khóa DevOps)

### Yêu cầu:
- Đảm bảo rằng bạn đã build frontend & backend Docker Image sau đó push thành công lên ECR repository.
- Sử dụng bộ terraform được cung cấp sẵn trong thư mục "terraform" file hướng dẫn "command.sh" để triển khai stack.
- Truy cập và test hoạt động của ứng dụng.

### Các step thực hiện.
- Để cho đơn giản, các bạn tách source thành 2 repository trên Github như sau:
    - react-spring-mongo-full-stack-demo-frontend  
    - react-spring-mongo-full-stack-demo-backend  
- Chuẩn bị sẵn một Jenkins Server (chạy trên Ubuntu) đã cài đặt đầy đủ các công cụ cần thiết. Các bạn có thể tái sử dụng lại Jenkins server từ các bài lab trước.

### Step 1: Tạo build job cho FE.


### Step 2: Change code & Test việc release tự động. 


### Step 3: Tạo build project cho BE.


### Step 4: Change code & Test việc release tự động. 