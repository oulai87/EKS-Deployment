# Stage 0, "build-stage", based on Node.js, to build and compile the frontend
FROM node:lts as build-stage
WORKDIR /app
COPY package*.json /app/
RUN npm install
COPY ./ /app/
# Set NODE_OPTIONS environment variable to --openssl-legacy-provider
ENV NODE_OPTIONS=--openssl-legacy-provider

RUN npm run build
# Stage 1, based on Nginx, to have only the compiled app, ready for production with Nginx
FROM nginx:1.23-alpine
COPY --from=build-stage /app/build/ /usr/share/nginx/html/react-app
# Copy the default nginx.conf provided by tiangolo/node-frontend
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
