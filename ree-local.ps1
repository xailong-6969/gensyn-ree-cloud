$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ToolsDir = Join-Path $ScriptDir "local"

$Image = if ($env:REE_LOCAL_IMAGE) { $env:REE_LOCAL_IMAGE } else { "xailong6969/gensyn-ree-cloud:latest" }
$CacheDir = if ($env:REE_LOCAL_CACHE_DIR) { $env:REE_LOCAL_CACHE_DIR } else { Join-Path $ScriptDir ".ree-local\cache" }
$ReceiptsDir = if ($env:REE_LOCAL_RECEIPTS_DIR) { $env:REE_LOCAL_RECEIPTS_DIR } else { Join-Path $ScriptDir "receipts" }

New-Item -ItemType Directory -Force -Path $CacheDir | Out-Null
New-Item -ItemType Directory -Force -Path $ReceiptsDir | Out-Null

$gpuArgs = @()
if (Get-Command nvidia-smi -ErrorAction SilentlyContinue) {
    $gpuArgs = @("--gpus", "all")
}

docker pull $Image

$dockerArgs = @(
    "run", "--rm", "-it"
) + $gpuArgs + @(
    "-e", "REE_CLOUD_MODE=1",
    "-e", "REE_HOST_CACHE=/workspace/.cache",
    "-e", "REE_RECEIPTS_DIR=/workspace/receipts",
    "-v", "${CacheDir}:/workspace/.cache",
    "-v", "${ReceiptsDir}:/workspace/receipts",
    "-v", "${ToolsDir}:/opt/ree-local-tools:ro",
    "--workdir", "/opt/ree-cloud",
    "--entrypoint", "/bin/bash",
    $Image,
    "--rcfile", "/opt/ree-local-tools/ree-local-bashrc", "-i"
)

& docker @dockerArgs
