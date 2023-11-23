FROM dpage/pgadmin4 as pgadmin4

# Switch to root user for installation
USER root

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Install Python if not already installed
RUN yum install -y python3

# Set execute permissions for the entrypoint script
RUN chmod +x /entrypoint.sh

# Adjust ownership of the necessary directories and files
RUN chown -R 1001:0 /pgadmin4 /var/lib/pgadmin && \
    chmod -R g=u /pgadmin4 /var/lib/pgadmin && \
    chmod -R g=u /pgadmin4 /entrypoint.sh


# Switch back to non-root user
USER 1001

# Expose port and set entrypoint
EXPOSE 80 443

# Run the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
