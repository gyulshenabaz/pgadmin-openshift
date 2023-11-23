# Use the official pgAdmin 4 Docker image
FROM dpage/pgadmin4

# Set the user to run pgAdmin 4
USER root

# Install sudo (if not already installed)
RUN apt-get update && \
    apt-get install -y sudo && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m -d /home/pgadmin -s /bin/bash pgadmin

# Allow the non-root user to run pgAdmin 4 commands with sudo without a password prompt
RUN echo 'pgadmin ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Switch to the non-root user
USER pgadmin

# Set the working directory to the home directory
WORKDIR /home/pgadmin

# Specify the entry point command
ENTRYPOINT ["/entrypoint.sh"]

# Expose the pgAdmin 4 port
EXPOSE 5050
