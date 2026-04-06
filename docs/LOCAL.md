# Local PC Usage

This image can be used on a local PC too. The local flow keeps the official REE files untouched and runs the existing image directly on your machine.

## Quick Start

### Linux / WSL / Ubuntu

```bash
docker pull xailong6969/gensyn-ree-cloud:latest
docker run --rm -it --gpus all -e REE_CLOUD_MODE=1 --workdir /opt/ree-cloud --entrypoint /bin/bash xailong6969/gensyn-ree-cloud:latest
```

### Windows PowerShell

```powershell
docker pull xailong6969/gensyn-ree-cloud:latest
docker run --rm -it --gpus all -e REE_CLOUD_MODE=1 --workdir /opt/ree-cloud --entrypoint /bin/bash xailong6969/gensyn-ree-cloud:latest
```

## Inside the container

You will start in:

```text
/opt/ree-cloud
```

Run REE with:

```bash
python3 ree.py
```

## Exit and Re-run

To leave the container:

```bash
exit
```

To use it again later:

1. Open your normal host terminal
2. Run the same `docker run ...` command again
3. Inside the container, run `python3 ree.py`

Important:

- Do not run `docker run ...` from inside the container shell
- If your prompt looks like `root@<container-id>:/#`, you are already inside the container

## Recommended Local Launcher Scripts

If you want better cache and receipt persistence, use the included launcher scripts instead of the bare `docker run` command.

### Linux / WSL / Ubuntu

```bash
./ree-local.sh
```

### Windows PowerShell

```powershell
.\ree-local.ps1
```

These scripts:

- pull `xailong6969/gensyn-ree-cloud:latest`
- open a shell directly in `/opt/ree-cloud`
- mount local cache and receipts directories
- keep the existing cloud image and official REE files untouched

## Better Receipt Visibility

If you use the local launcher scripts, you can run:

```bash
ree-run
```

That wrapper copies the newest receipt to:

```text
/workspace/receipts/latest-receipt.json
```

It also keeps a copy with the original generated filename in `/workspace/receipts/`.

## Local Directories

By default, the launcher scripts create:

- `.ree-local/cache`
- `receipts`

You can override them with:

- `REE_LOCAL_CACHE_DIR`
- `REE_LOCAL_RECEIPTS_DIR`
- `REE_LOCAL_IMAGE`

## Notes

- This local flow uses the existing cloud image as-is.
- It does not add Jupyter.
- It does not change `ree.py`, `ree.sh`, or the existing cloud adapter diff.
