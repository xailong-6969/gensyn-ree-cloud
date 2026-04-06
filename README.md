# gensyn-ree-cloud

Portable, cloud-friendly Docker image for running [Gensyn REE](https://github.com/gensyn-ai/ree) on cloud GPU platforms like **Vast.ai** and **QuickPod**.

## What is Gensyn REE?

**REE (Reproducible Execution Environment)** is an open-source tool by [Gensyn](https://gensyn.ai) that enables cryptographically verifiable, reproducible AI inference.

When you run a model through REE:
1. You provide a model name and a prompt
2. REE executes the inference inside a deterministic runtime
3. It produces a **receipt** — a cryptographic proof that the output was generated correctly
4. Anyone can independently verify the result

## The Problem

The official Gensyn REE requires Docker to run — `ree.sh` pulls a Docker image, sets up volume mounts, and launches `gensyn-sdk` inside a new container via `docker run`.

On cloud GPU platforms like Vast.ai and QuickPod, **you're already inside a container**. Docker is not available because these platforms don't grant privileged access. You can't install Docker inside Docker without privileged mode, so the official REE flow simply doesn't work.

This image solves that by packaging the REE runtime and running `gensyn-sdk` directly — no Docker-in-Docker needed.

## How This Image Works

The official REE flow is designed for local machines with Docker. This image adapts it for **cloud GPU platforms** where the runtime is already inside a container.

**Build time:** clones the [official REE wrapper](https://github.com/gensyn-ai/ree), applies a cloud-compatibility diff (`diffs/ree-cloud-adapter.diff`), and packages everything into the official `gensynai/ree` base image.

**Runtime:** prepares cache directories, launches a Jupyter terminal, and lets you run `python3 ree.py`.

---

## Usage Guides

| Environment | Guide |
|-------------|-------|
| Vast.ai | [Go to Vast.ai setup](#vastai-setup) |
| QuickPod | [Go to QuickPod setup](#quickpod-setup) |
| Local PC | [Go to Local PC usage](#local-pc-usage) |
| Local PC details | [Open docs/LOCAL.md](docs/LOCAL.md) |

---

## Vast.ai Setup

### 1. Open the Template

Click the link below to use the pre-configured Vast.ai template:

[**Launch Gensyn REE Cloud on Vast.ai**](https://cloud.vast.ai/?ref_id=244571&creator_id=244571&name=Gensyn%20REE%20Cloud)

### 2. Choose a GPU

Select any **NVIDIA 3000, 4000, or 5000 series** GPU (e.g. RTX 3060, RTX 4070, RTX 5070).

### 3. Run REE

Once the instance is ready, open the Jupyter terminal and run:

```bash
python3 ree.py
```

![Vast.ai demo](assets/vast-demo.gif)

---

## QuickPod Setup

### 1. Create a Pod

| Setting | Value |
|---------|-------|
| Image | `xailong6969/gensyn-ree-cloud:latest` |
| Docker options | `-p 8080:8080` |
| On-start script | `exec bash -lc '/opt/ree-cloud/quickpod-start.sh'` |
| Storage | 50 GB |

### 2. Get the Terminal URL

Check pod logs for the access banner:

```
╔════════════════════════════════════════════════════════════╗
║            🚀 QuickPod Jupyter Terminal Ready!           ║
╠════════════════════════════════════════════════════════════╣
║  Terminal: http://<your-ip>:<port>/terminals/1?token=...  ║
║  Token:    <your-token>                                   ║
╚════════════════════════════════════════════════════════════╝
```

### 3. Run REE

Open the terminal URL and run:

```bash
python3 ree.py
```

![QuickPod demo](assets/quickpod-demo.gif)

---

## Gensyn Official Documentation

| Resource | Link |
|----------|------|
| Get Started | [docs.gensyn.ai/tech/ree/get-started](https://docs.gensyn.ai/tech/ree/get-started) |
| Using the TUI | [docs.gensyn.ai/tech/ree/using-the-tui](https://docs.gensyn.ai/tech/ree/using-the-tui) |
| Supported Models | [docs.gensyn.ai/tech/ree/supported-models](https://docs.gensyn.ai/tech/ree/supported-models) |
| Receipts | [docs.gensyn.ai/tech/ree/receipts](https://docs.gensyn.ai/tech/ree/receipts) |
| Examples | [docs.gensyn.ai/tech/ree/examples](https://docs.gensyn.ai/tech/ree/examples) |
| Advanced Usage | [docs.gensyn.ai/tech/ree/advanced-usage](https://docs.gensyn.ai/tech/ree/advanced-usage) |
| Troubleshooting | [docs.gensyn.ai/tech/ree/troubleshooting](https://docs.gensyn.ai/tech/ree/troubleshooting) |
| Official REE Repo | [github.com/gensyn-ai/ree](https://github.com/gensyn-ai/ree) |

---

## Docker Hub

Pull the image directly:

```bash
docker pull xailong6969/gensyn-ree-cloud:latest
```

[**xailong6969/gensyn-ree-cloud** on Docker Hub](https://hub.docker.com/r/xailong6969/gensyn-ree-cloud)

---

## Local PC Usage

You can also run this image locally on a machine with Docker and an NVIDIA GPU.

### 1. Pull the image

```bash
docker pull xailong6969/gensyn-ree-cloud:latest
```

### 2. Start a shell inside the container

```bash
docker run --rm -it --gpus all -e REE_DIRECT_MODE=1 --workdir /opt/ree-cloud --entrypoint /bin/bash xailong6969/gensyn-ree-cloud:latest
```

### 3. Run REE inside the container

```bash
python3 ree.py
```

### Exit the container

When you are done, leave the container with:

```bash
exit
```

### Re-run later

If you want to use it again later:

1. Open your normal host terminal
2. Run the same `docker run ...` command again
3. Inside the container, run `python3 ree.py`

Important:

- Do not run `docker run ...` from inside the container shell
- If your prompt looks like `root@<container-id>:/#`, you are already inside the container
- For the full local guide with launcher scripts and receipt persistence, see [docs/LOCAL.md](docs/LOCAL.md)

---

## License

[MIT](LICENSE)
