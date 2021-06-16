# Our base image
FROM ubuntu:latest
 
# Identify the maintainer of an image
LABEL maintainer="a.novogrodsky@gmail.com"
 
# Update the image to the latest packages
RUN apt-get update && apt-get upgrade -y
 
# Install NGINX
RUN apt-get install nginx -y

# Add environment variable
ENV DEVOPS="Novogrodski"
 
# Expose port 80
EXPOSE 80
 
# Start up NGINX within our Container
CMD ["nginx", "-g", "daemon off;"]
