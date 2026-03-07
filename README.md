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

> If you previously saw `sed: couldn't open temporary file ... Permission denied` at startup (common after forcing a non-default container user), rebuild with this repo's current Dockerfile. It keeps the base image startup user flow intact and copies the plugin into the Jetty webapp path used by GeoNetwork 4.2 images.

## Manual verification

1. Open `http://localhost:8080/geonetwork`.
2. Login with default credentials:
   - username: `admin`
   - password: `admin`
3. Open **Admin console** → **Metadata & templates**.
4. Confirm `iso19139.gemini23` appears in the schema/template list.

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
