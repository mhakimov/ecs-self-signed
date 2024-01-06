# Use an official Apache base image
FROM httpd:2.4

# Copy custom configuration file if needed
# COPY ./my-httpd.conf /usr/local/apache2/conf/httpd.conf

# Copy "Hello, World!" HTML file to the document root
COPY ./index.html /usr/local/apache2/htdocs/

# Expose the default HTTP port
EXPOSE 80

# Start Apache in the foreground
CMD ["httpd", "-D", "FOREGROUND"]