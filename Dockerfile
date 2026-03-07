# syntax=docker/dockerfile:1.6

FROM maven:3.9.9-eclipse-temurin-11 AS plugin-builder

ARG GEMINI_REPO=https://github.com/AstunTechnology/iso19139.gemini23.git
ARG GEMINI_BRANCH=4.2.x

WORKDIR /build
RUN git clone --depth 1 --branch "${GEMINI_BRANCH}" "${GEMINI_REPO}" plugin
WORKDIR /build/plugin
RUN mvn -B -DskipTests package

FROM geonetwork:4.2

ARG GEONETWORK_HOME=/opt/geonetwork

# Install the GEMINI 2.3 schema plugin into GeoNetwork.
COPY --from=plugin-builder /build/plugin/src/main/plugin/iso19139.gemini23 \
  ${GEONETWORK_HOME}/WEB-INF/data/config/schema_plugins/iso19139.gemini23
COPY --from=plugin-builder /build/plugin/target/schema-iso19139.gemini23-*.jar \
  ${GEONETWORK_HOME}/WEB-INF/lib/

EXPOSE 8080
