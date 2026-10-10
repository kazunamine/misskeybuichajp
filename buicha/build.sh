#!/usr/bin/env bash
# このフォークのソースから linux/amd64 の Docker イメージをビルドする。
# どのディレクトリから実行しても repo ルートを自動解決する。
set -euo pipefail

BUICHA_REV=${BUICHA_REV:-1}

log() { echo "[build] $*"; }
err() { echo "[build] ERROR: $*" >&2; }

SAVE=1
ALLOW_DIRTY=0
for arg in "$@"; do
  case "$arg" in
    --no-save) SAVE=0 ;;
    --allow-dirty) ALLOW_DIRTY=1 ;;
    -h|--help) echo "Usage: [BUICHA_REV=1] $0 [--no-save] [--allow-dirty]"; exit 0 ;;
    *) err "unknown option: $arg"; exit 2 ;;
  esac
done

for cmd in docker git gzip; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    if [ "$cmd" = "docker" ]; then
      err "docker not found (Docker Desktop / OrbStack を起動してください)"
    else
      err "$cmd not found (インストールしてください)"
    fi
    exit 1
  fi
done
if ! docker buildx version >/dev/null 2>&1; then
  err "docker buildx not available (Docker Desktop / OrbStack を起動し、buildx を有効にしてください)"
  exit 1
fi

REPO_ROOT="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
cd "$REPO_ROOT"

if [ -n "$(git status --porcelain)" ]; then
  if [ "$ALLOW_DIRTY" -eq 1 ]; then
    log "WARNING: working tree is dirty (--allow-dirty で続行)"
  else
    err "working tree is dirty. commit/stash するか --allow-dirty を付けてください。"
    git status --short >&2
    exit 1
  fi
fi

# package.json の "version" を取得
VERSION="$(sed -n 's/^[[:space:]]*"version":[[:space:]]*"\([^"]*\)".*/\1/p' package.json | head -n1)"
if [ -z "$VERSION" ]; then
  err "version not found in package.json"
  exit 1
fi

IMAGE="buicha/misskey:${VERSION}-buicha.${BUICHA_REV}"
DIST_DIR="$REPO_ROOT/buicha/dist"
ARCHIVE="$DIST_DIR/misskey-${VERSION}-buicha.${BUICHA_REV}.tar.gz"

log "step 1/3: git submodule update --init"
git submodule update --init

log "step 2/3: docker buildx build ($IMAGE, linux/amd64)"
docker buildx build --platform linux/amd64 --load -t "$IMAGE" .

if [ "$SAVE" -eq 1 ]; then
  log "step 3/3: save to $ARCHIVE"
  mkdir -p "$DIST_DIR"
  docker save "$IMAGE" | gzip > "$ARCHIVE"
  log "done: $ARCHIVE"
else
  log "step 3/3: skipped (--no-save)"
  log "done: $IMAGE"
fi
