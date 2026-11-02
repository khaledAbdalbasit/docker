
# Stage 1: Build Laravel frontend assets
FROM node:22 AS assets-builder

WORKDIR /var/www

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# Stage 2: Run Nginx
FROM nginx:alpine

COPY ./docker/production/nginx/nginx.conf /etc/nginx/nginx.conf
COPY --from=assets-builder /var/www/public /var/www/public

WORKDIR /var/www/public

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
