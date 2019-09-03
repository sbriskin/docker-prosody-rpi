FROM arm32v7/alpine:latest

RUN apk update && \
    apk add bash perl prosody && \
    rm -rf /var/cache/apk/* && \
    mkdir /app

RUN sed -i '1s/^/daemonize = false;\n/' /etc/prosody/prosody.cfg.lua && \
    perl -i -pe 'BEGIN{undef $/;} s/^log = {.*?^}$/log = {\n    {levels = {min = "info"}, to = "console"};\n}/smg' /etc/prosody/prosody.cfg.lua

RUN mkdir -p /var/run/prosody && chown prosody:prosody /var/run/prosody

EXPOSE 80 443 5222 5269 5347 5280 5281

COPY prosody.sh /app/prosody.sh
RUN chmod 755 /app/prosody.sh
ENTRYPOINT ["/app/prosody.sh"]

USER prosody
ENV __FLUSH_LOG yes
CMD ["prosody"]
