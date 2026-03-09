FROM maven:3.9.11-eclipse-temurin-17 AS plugin-builder

WORKDIR /build

COPY src/main/resources ./src/main/resources
COPY src/main/plugin/iso19139.gemini23 ./src/main/plugin/iso19139.gemini23
COPY src/main/config/translations/en-schema-iso19139.gemini23.json ./src/main/config/translations/en-schema-iso19139.gemini23.json

RUN cat > pom.xml <<'POM'
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>org.geonetwork-opensource.schemas</groupId>
  <artifactId>schema-iso19139.gemini23</artifactId>
  <version>4.2.4-SNAPSHOT</version>
  <packaging>jar</packaging>

  <build>
    <resources>
      <resource>
        <directory>src/main/config/translations</directory>
        <targetPath>META-INF/catalog/locales</targetPath>
      </resource>
      <resource>
        <directory>src/main/resources</directory>
      </resource>
      <resource>
        <directory>src/main/plugin</directory>
        <targetPath>plugin</targetPath>
      </resource>
    </resources>
  </build>
</project>
POM

RUN mvn -B -DskipTests package

FROM scratch AS plugin-jar-export

COPY --from=plugin-builder /build/target/schema-iso19139.gemini23-4.2.4-SNAPSHOT.jar /schema-iso19139.gemini23-4.2.4-SNAPSHOT.jar

FROM geonetwork:4.2

USER root

COPY --from=plugin-builder /build/target/schema-iso19139.gemini23-4.2.4-SNAPSHOT.jar /tmp/schema-iso19139.gemini23-4.2.4-SNAPSHOT.jar
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
    lib_target="$webapp_root/WEB-INF/lib"; \
    mkdir -p "$(dirname "$schema_target")" "$locale_target" "$lib_target"; \
    rm -rf "$schema_target"; \
    cp -a /tmp/iso19139.gemini23 "$schema_target"; \
    cp /tmp/en-schema-iso19139.gemini23.json "$locale_target/en-schema-iso19139.gemini23.json"; \
    cp /tmp/schema-iso19139.gemini23-4.2.4-SNAPSHOT.jar "$lib_target/"; \
    if [ -f "$lib_target/groovy-2.5.5.jar" ] && [ -f "$lib_target/groovy-all-2.4.21.jar" ]; then \
      rm -f "$lib_target/groovy-all-2.4.21.jar"; \
    fi; \
    chown -R jetty:jetty "$schema_target" "$locale_target/en-schema-iso19139.gemini23.json" "$lib_target/schema-iso19139.gemini23-4.2.4-SNAPSHOT.jar"

USER jetty
