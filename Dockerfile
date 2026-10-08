FROM debian:bookworm-slim

WORKDIR /app
COPY app/app.sh /app/app.sh
RUN chmod +x /app/app.sh

ENTRYPOINT ["/app/app.sh"]
CMD ["help"]