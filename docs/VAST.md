# Vast.ai template

## Recommended settings

- Template name: `Gensyn REE Cloud`
- Description: `Portable Gensyn REE wrapper with Jupyter terminal support`
- Image path: `xailong6969/gensyn-ree-cloud`
- Version tag: `latest`
- Launch mode: `Jupyter-python notebook + SSH`
- Use Jupyter Lab interface: optional, but recommended
- Jupyter direct HTTPS: optional, depends on your Vast setup
- Ports: leave blank
- Docker auth: leave blank
- Disk: `40 GB` minimum, `50 GB` safer
- Visibility: test as `Private` first

## On-start script

```bash
#!/usr/bin/env bash
set -euo pipefail
exec bash -lc '/opt/ree-cloud/vast-on-start.sh'
```

## Accessing the TUI

1. Launch the instance.
2. Open Jupyter from the Vast instance page.
3. Open a Terminal in Jupyter.
4. Run:

```bash
python3 ree.py
```

If your terminal opens in a different directory, run:

```bash
cd /opt/ree-cloud
python3 ree.py
```

Optional least-privilege launch:

```bash
/opt/ree-cloud/run-ree-as-user.sh
```

## Notes

- Vast Jupyter mode replaces the image entrypoint, so the on-start script is required.
- The startup script writes helper instructions to `/workspace/REE-GUIDE.txt`.
- This repo intentionally does not auto-run REE inside `screen` or `tmux` by default, because direct `python3 ree.py` works better in the browser terminal.