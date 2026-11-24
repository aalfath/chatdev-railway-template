# Deploy and Host ChatDev on Railway

ChatDev 2.0 (DevAll) by OpenBMB is an open-source, zero-code platform for multi-agent LLM workflows. You pick or draw a workflow of agents in a web console, give it a task, and the agents plan, write, test and document software (or reports, data charts and research) while you watch each step live.

## About Hosting ChatDev

This template runs ChatDev `v2.2.0`, built from the tagged upstream source, as two services. `web` is the public console: Caddy serves the Vue UI behind a login with a generated password and forwards API and WebSocket calls over Railway's private network. `backend` is the FastAPI workflow server. It has no public domain and keeps workflows, run outputs, logs and its SQLite graph store on a volume at `/data`. The only prompt is your LLM API key. After deploy, open the `web` service's domain, sign in as `admin` with the `CHATDEV_PASSWORD` value from the `web` service's Variables tab, open Launch, choose a workflow such as `ChatDev_v1` and give it a task.

## Common Use Cases

* Turn a one-line idea into a small working program written, reviewed and tested by a team of agents (the classic ChatDev "software company" workflow)
* Build and run your own multi-agent workflows in the visual editor: research, data visualisation, reflection loops, human-in-the-loop review
* Compare models and prompts on the same workflow by switching `BASE_URL` and `MODEL_NAME`

## Dependencies for ChatDev Hosting

* An API key for OpenAI or any OpenAI-compatible provider (OpenRouter, DeepSeek, Groq, a self-hosted vLLM or Ollama)
* A Railway volume for the backend (included)

### Deployment Dependencies

* ChatDev source and release notes: https://github.com/OpenBMB/ChatDev/releases/tag/v2.2.0
* ChatDev user guide: https://github.com/OpenBMB/ChatDev/tree/v2.2.0/docs/user_guide/en
* Template source (Dockerfiles, start scripts, changelog): https://github.com/aalfath/chatdev-railway-template

### Implementation Details

Services:

* `web` (public): Caddy 2.11.9 with the static ChatDev console. Every page and API call needs the login (`CHATDEV_USERNAME`, default `admin`, and the generated `CHATDEV_PASSWORD`). `/healthz` is the health check and answers only when the backend is up.
* `backend` (private): ChatDev's FastAPI server on port 6400, volume at `/data`.

Variables on `backend`: `API_KEY` (required, your provider key), `BASE_URL` (default `https://api.openai.com/v1`; set it to any OpenAI-compatible endpoint) and `MODEL_NAME` (default `gpt-4o`, used by workflows that read `${MODEL_NAME}`). Most shipped workflows name `gpt-4o` directly; with another provider, open the workflow in the editor and change the model name of each agent. Workflows that use Gemini models need a Gemini key and `BASE_URL`. Optional web tools work if you add `SERPER_DEV_API_KEY` or `JINA_API_KEY` on `backend`.

Runs cost tokens on your key: the `ChatDev_v1` workflow makes many model calls per task.

Safety: agents can run the Python code they write inside the backend container (with its file system and network access, but no Docker). Keep the password private. Uploading Python tools through `/api/tools/local` is blocked, because upstream added protection for it only after `v2.2.0`; add your own tools by mounting them in a fork instead.

Resources: the backend idles at about 150 MB and fits Railway's 0.5 GB Free-plan limit for normal runs; the web service needs about 30 MB.

Updates: the services build from the template repo. When we bump ChatDev, Railway shows an update for your project; read the repo's `CHANGELOG.md` before you apply it. Your workflows on the volume are kept; workflows that ship with ChatDev are added only if missing, so your edits are never overwritten.

## Why Deploy ChatDev on Railway?

<!-- Recommended: Keep this section as shown below -->
Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying ChatDev on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
<!-- End recommended section -->
