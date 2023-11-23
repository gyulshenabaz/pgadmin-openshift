FROM dpage/pgadmin4 as pgadmin4

# Switch to root user for installation
USER root

# Adjust ownership of the necessary directories and files
RUN chown -R 1001:0 /pgadmin4 /var/lib/pgadmin && \
    chmod -R g=u /pgadmin4 /var/lib/pgadmin

# Switch back to non-root user
USER 1001

# Expose port and set entrypoint
EXPOSE 80 443

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Run the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
