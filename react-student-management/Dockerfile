# Stage 1: Build static files
FROM node:20 AS builder
ENV PATH /app/node_modules/.bin:$PATH
WORKDIR /app/
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Serve static files with nginx
FROM nginx
COPY --from=builder /app/build/ /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
# COPY nginx.conf /etc/nginx/sites-available/default
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
