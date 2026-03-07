# GeoNetwork 4.2 + GEMINI 2.3 Docker image

This repository builds a runnable Docker image based on the official `geonetwork:4.2` image and installs the
[`iso19139.gemini23`](https://github.com/AstunTechnology/iso19139.gemini23/tree/4.2.x) schema plugin.

> GeoNetwork 4.2 requires Elasticsearch. The provided `docker-compose.yml` starts both services and wires GeoNetwork to Elasticsearch automatically.

## Build the image

```bash
docker compose build
```

## Run GeoNetwork + Elasticsearch

```bash
docker compose up -d
```

GeoNetwork will be available at:

- <http://localhost:8080/geonetwork>

Elasticsearch will be available at:

- <http://localhost:9200>

## Verify GEMINI 2.3 is installed manually

1. Open <http://localhost:8080/geonetwork>.
2. Log in with the default administrator account:
   - **Username:** `admin`
   - **Password:** `admin`
3. Open **Admin console**.
4. Go to **Metadata & templates**.
5. Confirm `iso19139.gemini23` appears in the list of standards/templates.

## Playwright end-to-end test

The Playwright test automates the same verification by:

- logging in as `admin` / `admin`
- opening the Admin console metadata section
- checking for `iso19139.gemini23` in the UI
- checking `/geonetwork/srv/api/schemas` includes `iso19139.gemini23`

Install dependencies and browser:

```bash
npm install
npm run test:e2e:install
```

Run tests (expects GeoNetwork stack to already be running at `http://localhost:8080`):

```bash
npm run test:e2e
```

Optional custom base URL:

```bash
BASE_URL=http://localhost:8080 npm run test:e2e
```

## Notes

- Plugin source branch is pinned to `4.2.x` via Docker build args.
- The build compiles the plugin with Maven in a separate stage, then copies both the plugin schema directory and JAR into GeoNetwork's plugin locations.
- Elasticsearch 7.17.15 is used because it is the version recommended for GeoNetwork 4.2 in the official image documentation.
