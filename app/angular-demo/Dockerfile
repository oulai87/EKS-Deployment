FROM node:lts as build

# Set the working directory
WORKDIR /usr/local/app

# Add the source code to app
COPY ./ /usr/local/app/

# Install all the dependencies
RUN npm install

# Set NODE_OPTIONS environment variable to --openssl-legacy-provider
ENV NODE_OPTIONS=--openssl-legacy-provider

# Generate the build of the application
RUN npm run build


# Stage 2: Serve app with nginx server

# Use official nginx image as the base image
FROM nginx:latest

# Copy nginx config file
COPY nginx.conf /etc/nginx/nginx.conf

# Copy the build output to replace the default nginx contents.
COPY --from=build /usr/local/app/dist/angular-demo /usr/share/nginx/html/angular-app

# Expose port 80
EXPOSE 80
