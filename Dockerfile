FROM ubuntu:16.04
MAINTAINER Daniel Berredo <danielberredo@gmail.com>

# Environment variables
ENV \
  ADMIN_BIND_ADDR="0.0.0.0" \
  ADMIN_TLS_ENABLED="false" \
  ADMIN_TLS_CRT="gophish_admin.crt" \
  ADMIN_TLS_KEY="gophish_admin.key" \
  WEB_BIND_ADDR="0.0.0.0" \
  WEB_TLS_ENABLED="false" \
  WEB_TLS_CRT="gophish_web.crt" \
  WEB_TLS_KEY="gophish_web.key"

RUN apt-get update && apt-get upgrade -y
RUN apt-get install openssl unzip -y
WORKDIR /
ADD gophish-v0.4-linux-32bit.zip gophish-v0.4-linux-32bit.zip
RUN unzip gophish-v0.4-linux-32bit.zip && mv gophish-v0.4-linux-32bit gophish

WORKDIR /gophish
RUN openssl req -subj '/CN=gophish.local/O=My Company Name LTD./C=US' -newkey rsa:2048 -nodes -keyout "${ADMIN_TLS_KEY}" -x509 -days 365 -out "${ADMIN_TLS_CRT}"
RUN openssl req -subj '/CN=gophish.local/O=My Company Name LTD./C=US' -newkey rsa:2048 -nodes -keyout "${WEB_TLS_KEY}" -x509 -days 365 -out "${WEB_TLS_CRT}"
RUN /bin/echo "{" > ./config.json && \
    /bin/echo "	\"admin_server\": {" >> ./config.json && \
    /bin/echo "		\"listen_url\": \"${ADMIN_BIND_ADDR}:3333\"," >> ./config.json && \
    /bin/echo "		\"use_tls\": ${ADMIN_TLS_ENABLED}," >> ./config.json && \
    /bin/echo "		\"cert_path\": \"${ADMIN_TLS_CRT}\"," >> ./config.json && \
    /bin/echo "		\"key_path\": \"${ADMIN_TLS_KEY}\"" >> ./config.json && \
    /bin/echo "	}," >> ./config.json && \
    /bin/echo "	\"phish_server\": {" >> ./config.json && \
    /bin/echo "		\"listen_url\": \"${WEB_BIND_ADDR}:80\"," >> ./config.json && \
    /bin/echo "		\"use_tls\": ${WEB_TLS_ENABLED}," >> ./config.json && \
    /bin/echo "		\"cert_path\": \"${WEB_TLS_CRT}\"," >> ./config.json && \
    /bin/echo "		\"key_path\": \"${WEB_TLS_KEY}\"" >> ./config.json && \
    /bin/echo "	}," >> ./config.json && \
    /bin/echo "	\"db_name\": \"sqlite3\"," >> ./config.json && \
    /bin/echo "	\"db_path\": \"gophish.db\"," >> ./config.json && \
    /bin/echo "	\"migrations_prefix\": \"db/db_\"" >> ./config.json && \
    /bin/echo "}" >> ./config.json



EXPOSE 80 443 3333

CMD ["/gophish/gophish"]
