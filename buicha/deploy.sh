#!/usr/bin/env bash
# ビルド済みイメージを転送して docker load するだけ。
# 本番 compose の書き換え・再起動(up)は行わない（最後に手順を表示するのみ）。
# 設定は .deploy.env（.deploy.env.example 参照）で与える。
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 接続先などの設定は .deploy.env（gitignore 済み。例: .deploy.env.example）から読む
if [ -f "$ROOT_DIR/.deploy.env" ]; then
  # shellcheck disable=SC1091
  . "$ROOT_DIR/.deploy.env"
fi

TARGET_HOST=${TARGET_HOST:-}
TARGET_USER=${TARGET_USER:-$USER}
SSH_PORT=${SSH_PORT:-22}
SSH_KEY=${SSH_KEY:-}
BIND_IFACE=${BIND_IFACE:-}
REMOTE_COMPOSE_FILES=${REMOTE_COMPOSE_FILES:-}
COMPOSE_PROJECT=${COMPOSE_PROJECT:-misskey}
COMPOSE_FILE_FOR_UP=${COMPOSE_FILE_FOR_UP:-}

DRY_RUN=0
ARCHIVE=""
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    -h|--help) echo "Usage: $0 [--dry-run] [path/to/misskey-*.tar.gz]"; exit 0 ;;
    -*) echo "[deploy] ERROR: unknown option: $arg" >&2; exit 2 ;;
    *) ARCHIVE="$arg" ;;
  esac
done

log() { echo "[deploy] $*"; }

if [ -z "$TARGET_HOST" ]; then
  echo "[deploy] ERROR: TARGET_HOST is not set (see .deploy.env.example)" >&2
  exit 1
fi

if [ -z "$ARCHIVE" ]; then
  ARCHIVE="$(ls -t "$ROOT_DIR"/dist/*.tar.gz 2>/dev/null | head -n1 || true)"
  if [ -z "$ARCHIVE" ]; then
    echo "[deploy] ERROR: no tar.gz given and none found in dist/" >&2
    exit 1
  fi
  log "using latest: $ARCHIVE"
fi

if [ "$DRY_RUN" -eq 0 ] && [ ! -f "$ARCHIVE" ]; then
  echo "[deploy] ERROR: file not found: $ARCHIVE" >&2
  exit 1
fi

base="$(basename "$ARCHIVE")"
# misskey-<ver>-buicha.<rev>.tar.gz -> buicha/misskey:<ver>-buicha.<rev>
tag="${base#misskey-}"
tag="${tag%.tar.gz}"
IMAGE="buicha/misskey:${tag}"

DEST="${TARGET_USER}@${TARGET_HOST}"
REMOTE_TMP="/tmp/$base"

# ssh / scp 共通オプション（bash 配列）
COMMON_OPTS=()
if [ -n "$SSH_KEY" ]; then
  COMMON_OPTS+=(-i "$SSH_KEY" -o IdentitiesOnly=yes)
fi
if [ -n "$BIND_IFACE" ]; then
  COMMON_OPTS+=(-o "BindInterface=$BIND_IFACE")
fi
SSH_OPTS=(-p "$SSH_PORT" "${COMMON_OPTS[@]}")
SCP_OPTS=(-P "$SSH_PORT" "${COMMON_OPTS[@]}")

# ローカルの sha256
if [ -f "$ARCHIVE" ]; then
  LOCAL_SHA="$(shasum -a 256 "$ARCHIVE" | awk '{print $1}')"
else
  LOCAL_SHA="<local-sha256>"
fi

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run]'; printf ' %q' "$@"; printf '\n'
  else
    "$@"
  fi
}

log "target: $DEST port=$SSH_PORT key=${SSH_KEY:-(none)} bind=${BIND_IFACE:-(none)}"
log "image: $IMAGE"
log "local sha256: $LOCAL_SHA"

log "step 1/3: scp"
run scp "${SCP_OPTS[@]}" "$ARCHIVE" "$DEST:$REMOTE_TMP"

log "step 2/3: verify sha256 on remote"
if [ "$DRY_RUN" -eq 1 ]; then
  run ssh "${SSH_OPTS[@]}" "$DEST" "sha256sum '$REMOTE_TMP'"
  log "(dry-run) expect remote sha256 == $LOCAL_SHA"
else
  REMOTE_SHA="$(ssh "${SSH_OPTS[@]}" "$DEST" "sha256sum '$REMOTE_TMP'" | awk '{print $1}')"
  if [ "$REMOTE_SHA" != "$LOCAL_SHA" ]; then
    echo "[deploy] ERROR: sha256 mismatch (local=$LOCAL_SHA remote=$REMOTE_SHA). aborting." >&2
    exit 1
  fi
  log "sha256 OK"
fi

log "step 3/3: docker load"
run ssh "${SSH_OPTS[@]}" "$DEST" "sudo docker load -i '$REMOTE_TMP'"

# ssh 接続用の表示文字列
SSH_HINT="ssh -p $SSH_PORT"
if [ -n "$SSH_KEY" ]; then
  SSH_HINT="$SSH_HINT -i $SSH_KEY -o IdentitiesOnly=yes"
fi
if [ -n "$BIND_IFACE" ]; then
  SSH_HINT="$SSH_HINT -o BindInterface=$BIND_IFACE"
fi
SSH_HINT="$SSH_HINT $DEST"

# image 置換コマンドの案内（compose ファイルごとに1行）
SED_LINES=""
for f in ${REMOTE_COMPOSE_FILES:-<compose-file>}; do
  SED_LINES="${SED_LINES}       sudo sed -i 's#\"image\": \"<OLD>\"#\"image\": \"$IMAGE\"#' $f
"
done
GREP_FILE="${REMOTE_COMPOSE_FILES%% *}"
GREP_FILE="${GREP_FILE:-<compose-file>}"
UP_FILE="${COMPOSE_FILE_FOR_UP:-<compose-file>}"

cat <<MSG

[deploy] 完了（本番 compose は変更していません。up も実行していません）。
次の手順はユーザーが手動で行ってください。

  0. 事前バックアップ（DB ダンプ・compose・設定ファイル等）を取得する

  1. 現在の image を控える（ロールバック用）
       $SSH_HINT
       sudo grep 'image' $GREP_FILE

  2. compose ファイルの image を置換する（<OLD> は手順1で控えた web の image 値。
     複数ファイルがある場合は同時に更新する）
${SED_LINES}     （web 以外のサービスの image を巻き込まないよう <OLD> は web の値を正確に指定する）

  3. web のみ切替
       sudo docker compose -p $COMPOSE_PROJECT -f $UP_FILE up -d --no-deps web

  4. 転送ファイルの後片付け
       sudo rm -f '$REMOTE_TMP'
MSG
