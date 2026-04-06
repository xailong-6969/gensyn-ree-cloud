# Local PC mode

This local flow does not modify or patch the official REE files. It uses new wrapper-owned launch scripts only.

## What it does

- pulls `xailong6969/gensyn-ree-cloud:latest`
- opens a shell directly in `/opt/ree-cloud`
- mounts local cache and receipts directories
- keeps the existing cloud image and official REE files untouched

## Linux / macOS

Run:

```bash
./ree-local.sh
```

## Windows PowerShell

Run:

```powershell
.\ree-local.ps1
```

## Inside the container

You will start in:

```text
/opt/ree-cloud
```

You can use either of these:

```bash
python3 ree.py
```

or:

```bash
ree-run
```

## Better receipt visibility

If you use `ree-run`, the wrapper also copies the newest receipt to:

```text
/workspace/receipts/latest-receipt.json
```

It also keeps a copy with the original generated filename in `/workspace/receipts/`.

## Local directories

By default, the launchers create:

- `.ree-local/cache`
- `receipts`

You can override them with:

- `REE_LOCAL_CACHE_DIR`
- `REE_LOCAL_RECEIPTS_DIR`
- `REE_LOCAL_IMAGE`

## Notes

- This flow uses the existing cloud image as-is.
- It does not add Jupyter.
- It does not change `ree.py`, `ree.sh`, or the existing cloud adapter diff.
