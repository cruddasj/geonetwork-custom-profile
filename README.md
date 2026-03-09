# GeoNetwork 4.2 + GEMINI 2.3 custom schema plugin

This repository builds a runnable Docker image based on the official `geonetwork:4.2` image and injects the custom `iso19139.gemini23` schema plugin from this repository.

## Run with Docker Compose

```bash
docker compose up -d --build
```

Services:

- `geonetwork` on `http://localhost:8080/geonetwork`
- `elasticsearch` on the internal compose network

The compose stack includes Elasticsearch as the search dependency required by GeoNetwork.

## Export the built plugin JAR to your local directory

The Dockerfile now exposes a dedicated build stage (`plugin-jar-export`) so you can write the built plugin JAR directly to the directory where you run the build:

```bash
docker build --target plugin-jar-export --output type=local,dest=. .
```

This will create:

- `./schema-iso19139.gemini23-4.2.4-SNAPSHOT.jar`


## Manual verification

1. Open `http://localhost:8080/geonetwork`.
2. Login with default credentials:
   - username: `admin`
   - password: `admin`
3. Open **Admin console** → **Metadata & templates**.
4. Confirm `GEMINI 2.3` appears in the schema/template list.

## Automated verification with Playwright

Install dev dependencies and run the test:

```bash
npm install
npx playwright install --with-deps chromium
scripts/run-e2e.sh
```

Or if GeoNetwork is already running:

```bash
GN_BASE_URL=http://127.0.0.1:8080 npx playwright test
```


## Troubleshooting Elasticsearch connection errors

If you see errors like `Could not connect to index 'gn-records' ... Connection refused`:

1. Ensure Elasticsearch is healthy:

   ```bash
   docker compose ps
   docker compose logs elasticsearch
   ```

2. Restart with a clean Elasticsearch volume if needed:

   ```bash
   docker compose down -v
   docker compose up -d --build
   ```

3. If startup logs show repeated Jetty warnings similar to `oeja.AnnotationParser ... scanned from multiple locations` for Groovy classes, rebuild the image so the Dockerfile cleanup step can remove the legacy duplicate `groovy-all-2.4.21.jar` when both Groovy JARs are present:

   ```bash
   docker compose build --no-cache geonetwork
   docker compose up -d
   ```


4. If Elasticsearch keeps restarting or never becomes healthy, check host kernel limits (common on Linux):

   ```bash
   docker compose logs elasticsearch
   sudo sysctl -w vm.max_map_count=262144
   ```

   Then restart: `docker compose down -v && docker compose up -d --build`.

This compose file now follows the official GeoNetwork 4.2 Docker environment variables for Elasticsearch (`ES_HOST`, `ES_PORT`, `ES_PROTOCOL`) and uses reduced JVM heap defaults (`512m`) to avoid common local-memory startup failures.

