# Use a base image with Python pre-installed
FROM alpine:latest

# Create a non-root user
RUN adduser -D -u 1001 pgadmin

# Copy the Python environment from the builder
COPY --from=env-builder /venv /venv

# Copy the tools and libraries from the builder
COPY --from=tool-builder /usr/local/pgsql /usr/local/
COPY --from=pg16-builder /usr/local/lib/libpq.so.5.16 /usr/lib/
COPY --from=pg16-builder /usr/lib/libzstd.so.1.5.5 /usr/lib/
COPY --from=pg16-builder /usr/lib/liblz4.so.1.9.4 /usr/lib/

# Create necessary symlinks
RUN ln -s libpq.so.5.16 /usr/lib/libpq.so.5 && \
    ln -s libpq.so.5.16 /usr/lib/libpq.so && \
    ln -s libzstd.so.1.5.5 /usr/lib/libzstd.so.1 && \
    ln -s liblz4.so.1.9.4 /usr/lib/liblz4.so.1

# Set the working directory
WORKDIR /pgadmin4

# Set environment variables
ENV PYTHONPATH=/pgadmin4

# Copy the code and docs
COPY --from=app-builder /pgadmin4/web /pgadmin4
COPY --from=docs-builder /pgadmin4/docs/en_US/_build/html/ /pgadmin4/docs
COPY pkg/docker/run_pgadmin.py /pgadmin4
COPY pkg/docker/gunicorn_config.py /pgadmin4
COPY pkg/docker/entrypoint.sh /entrypoint.sh

# License files
COPY LICENSE /pgadmin4/LICENSE
COPY DEPENDENCIES /pgadmin4/DEPENDENCIES

# Install runtime dependencies and configure everything in one RUN step
RUN apk --no-cache add \
        python3 \
        py3-pip \
        postfix \
        krb5-libs \
        libjpeg-turbo \
        shadow \
        sudo \
        libedit \
        libldap \
        libcap && \
    /venv/bin/python3 -m pip install --no-cache-dir gunicorn==20.1.0 && \
    find / -type d -name '__pycache__' -exec rm -rf {} + && \
    mkdir -p /var/lib/pgadmin && \
    chown pgadmin:root /var/lib/pgadmin && \
    chmod g=u /var/lib/pgadmin && \
    touch /pgadmin4/config_distro.py && \
    chown pgadmin:root /pgadmin4/config_distro.py && \
    chmod g=u /pgadmin4/config_distro.py && \
    chmod g=u /etc/passwd && \
    setcap CAP_NET_BIND_SERVICE=+eip /usr/bin/python3.11 && \
    echo "pgadmin ALL = NOPASSWD: /usr/sbin/postfix start" > /etc/sudoers.d/postfix && \
    echo "pgadmin ALL = NOPASSWD: /usr/sbin/postfix start" >> /etc/sudoers.d/postfix

# Switch to the non-root user
USER 1001

# Expose ports
EXPOSE 8080

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
