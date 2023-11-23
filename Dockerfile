FROM dpage/pgadmin4 as pgadmin4

USER root

# Adjust ownership of the necessary directories and files
RUN chown -R 1001:0 /pgadmin4 && \
    chmod -R g=u /pgadmin4 && \
    chmod -R g=u /var/lib/pgadmin

USER 1001

# Expose port and set entrypoint
EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]
