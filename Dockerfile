FROM geonetwork:4.2

USER root

COPY src/main/plugin/iso19139.gemini23 /tmp/iso19139.gemini23
COPY src/main/config/translations/en-schema-iso19139.gemini23.json /tmp/en-schema-iso19139.gemini23.json

RUN set -eux; \
    if [ -d /var/lib/jetty/webapps/geonetwork ]; then \
      webapp_root=/var/lib/jetty/webapps/geonetwork; \
    elif [ -d /usr/local/tomcat/webapps/geonetwork ]; then \
      webapp_root=/usr/local/tomcat/webapps/geonetwork; \
    else \
      echo "GeoNetwork webapp path not found" >&2; \
      exit 1; \
    fi; \
    schema_target="$webapp_root/WEB-INF/data/config/schema_plugins/iso19139.gemini23"; \
    locale_target="$webapp_root/WEB-INF/classes/META-INF/catalog/locales"; \
    mkdir -p "$(dirname "$schema_target")" "$locale_target"; \
    rm -rf "$schema_target"; \
    cp -a /tmp/iso19139.gemini23 "$schema_target"; \
    cp /tmp/en-schema-iso19139.gemini23.json "$locale_target/en-schema-iso19139.gemini23.json"; \
    chown -R jetty:jetty "$schema_target" "$locale_target/en-schema-iso19139.gemini23.json"

USER jetty
