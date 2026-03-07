FROM geonetwork:4.2

USER root

COPY src/main/plugin/iso19139.gemini23 /tmp/iso19139.gemini23
COPY src/main/config/translations/en-schema-iso19139.gemini23.json /tmp/en-schema-iso19139.gemini23.json

RUN set -eux; \
    schema_target="/usr/local/tomcat/webapps/geonetwork/WEB-INF/data/config/schema_plugins/iso19139.gemini23"; \
    locale_target="/usr/local/tomcat/webapps/geonetwork/WEB-INF/classes/META-INF/catalog/locales"; \
    mkdir -p "$(dirname "$schema_target")" "$locale_target"; \
    rm -rf "$schema_target"; \
    cp -a /tmp/iso19139.gemini23 "$schema_target"; \
    cp /tmp/en-schema-iso19139.gemini23.json "$locale_target/en-schema-iso19139.gemini23.json"; \
    chown -R 1000:1000 "$schema_target" "$locale_target/en-schema-iso19139.gemini23.json"

USER 1000
