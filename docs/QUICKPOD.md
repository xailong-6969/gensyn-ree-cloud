# QuickPod template

## Recommended settings

- Image: `xailong6969/gensyn-ree-cloud:latest`
- Docker options: `-p 8080:8080`
- On-start script: `exec bash -lc '/opt/ree-cloud/quickpod-start.sh'`
- Storage: `50 GB`

## What this does

The QuickPod startup path launches a real JupyterLab server inside the container.

That gives you:
- a proper browser Jupyter interface
- terminals rooted at `/opt/ree-cloud`
- a better REE TUI experience than the plain QuickPod Web Terminal renderer

## How to access it

1. Launch the pod.
2. Open the mapped port for internal `8080`.
3. Use the JupyterLab URL printed in the pod logs, or read:

```bash
cat /workspace/JUPYTER-INFO.txt
```

4. Open a terminal in JupyterLab.
5. Run:

```bash
python3 ree.py
```

Optional least-privilege launch:

```bash
/opt/ree-cloud/run-ree-as-user.sh
```
