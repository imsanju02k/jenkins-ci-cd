FROM nginx:alpine

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy your html file
COPY index.html /usr/share/nginx/html/index.html

# Expose nginx port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
