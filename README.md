# Liferay AI Chatbot using RAG

AI chatbot stack for Liferay DXP using a Retrieval-Augmented Generation (RAG) architecture.

This project was forked from:
https://github.com/orgs/qls-ai-chatbot/repositories

## Overview

The stack includes:

- Liferay DXP
- Spring Boot chatbot backend (`qls-ai-chatbot-etc-backend`)
- Ollama (LLM runtime)
- txtai (semantic index)
- Elasticsearch + Kibana
- MySQL

Everything is orchestrated with Docker Compose.

## Quick Start

### 1) Before You Start

1. Install prerequisites:
	 - Docker Engine with Docker Compose
	 - NVIDIA GPU support for Docker (GPU is required by the startup script)
	 - `sudo` access for Docker commands used in project scripts
2. Clone the repository and move to the root folder.
3. Create your local environment file:

```bash
cp .env.example .env
```

4. Update `.env` with values that match your machine:
	 - `LIFERAY_LICENSE_FILE_PATH`: path to your Liferay license XML
	 - Host ports (`LIFERAY_HOST_PORT`, `CHATBOT_BACKEND_HOST_PORT`, `TXTAI_HOST_PORT`, etc.)
	 - `AI_CHATBOT_BACKEND_SPRING_PROFILES_ACTIVE` (`localdocker` by default)
5. Make sure the license file exists at the path configured in `.env`.

Important defaults from `.env.example`:

- `LIFERAY_HOST_PORT=8080`
- `CHATBOT_BACKEND_HOST_PORT=58081`
- `TXTAI_HOST_PORT=8001`
- `OLLAMA_HOST_PORT=11434`

### 2) Start the Platform

From the repository root:

```bash
./scripts/start.sh
```

What this does:

- Verifies Docker GPU availability
- Builds images and starts all services with `docker compose up -d --build`
- Prints current container status

After containers are running, copy your Liferay license into the Liferay container:

```bash
./scripts/copy-license.sh
```

You can then access:

- Liferay: `http://localhost:${LIFERAY_HOST_PORT}`
- Chatbot backend: `http://localhost:${CHATBOT_BACKEND_HOST_PORT}`
- txtai API: `http://localhost:${TXTAI_HOST_PORT}`
- Kibana: `http://localhost:${KIBANA_HOST_PORT}`
- Ollama API: `http://localhost:${OLLAMA_HOST_PORT}`

To stop the stack:

```bash
./scripts/stop.sh
```

### 3) Deploy Changes

Use this when you update Liferay client extensions or backend artifacts and need to deploy them into the running environment.

From the repository root:

```bash
./scripts/deploy.sh
```

What this does:

- Runs `./gradlew deploy` from `liferay/workspace`
- Detects the running Liferay container
- Streams Liferay logs so you can verify deployment

#### Troubleshooting (`deploy.sh`)
If `./scripts/deploy.sh` fails, use the following checks.

1. Make sure you are running the script from the repository root:

```bash
cd /path/to/qls-ai-chatbot
./scripts/deploy.sh
```

2. If you get a Gradle permission error (`Permission denied`), fix execution rights and run deploy manually:

```bash
cd liferay/workspace
chmod +x gradlew
./gradlew deploy
```

3. If the script reports that no Liferay container is running, start the stack and retry:

```bash
cd /path/to/qls-ai-chatbot
./scripts/start.sh
./scripts/deploy.sh
```

4. If deployment completes but nothing appears in Liferay, inspect logs directly:

```bash
sudo docker compose ps
sudo docker logs --follow "$(sudo docker ps --filter "name=liferay" --format '{{.Names}}' | head -n 1)"
```

5. If needed, re-run deployment from the workspace for clearer Gradle output:

```bash
cd liferay/workspace
./gradlew deploy --stacktrace
```

## Spring Boot Configuration Notes

These are the key points to know for the chatbot backend configuration.

### Active profile

- The profile is controlled by `AI_CHATBOT_BACKEND_SPRING_PROFILES_ACTIVE` in `.env`.
- Default is `localdocker`.

### Profile behavior

- `localdocker` profile uses Docker service hostnames (for example `ollama:11434` and `liferay:8080`).
- `local` profile uses localhost endpoints (for example `localhost:11434` and `localhost:8080`).

### Most important properties

- Liferay domain and protocol:
	- `com.liferay.lxc.dxp.domains`
	- `com.liferay.lxc.dxp.mainDomain`
	- `com.liferay.lxc.dxp.server.protocol`
- Ollama model endpoints and model options:
	- `langchain4j.ollama.chat-model.*`
	- `langchain4j.ollama.streaming-chat-model.*`
- API and runtime:
	- `assistant.api.cors.allowed-origins`
	- `server.port` (default `58081`)
- Liferay OAuth integration:
	- `liferay.oauth.application.external.reference.codes`
	- `liferay.oauth.urls.excludes`

### Operational guidance

- Keep `server.port` aligned with `CHATBOT_BACKEND_HOST_PORT` in `.env`.
- If Liferay runs on a non-default host/port, update the Liferay domain properties accordingly.
- If Ollama is moved to another endpoint or model, update `langchain4j.ollama.*` properties to match.
- Keep CORS origins synchronized with your frontend URL(s) to avoid browser blocking.

## TODO

- Understand why the license is not persisted and must be redeployed on each startup.
- Inspect kibana index to see txtai embeddings effect inside index
- Inspect custom search blueprint


