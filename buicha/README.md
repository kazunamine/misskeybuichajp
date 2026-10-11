# ぶいちゃすきー (misskey.buicha.jp) 用フォーク

misskey.buicha.jp（ぶいちゃすきー、VRChatter 向け Misskey）用の [Misskey](https://github.com/misskey-dev/misskey) フォークです。ログイン前画面をブランディングし、Buicha.jp のサービスポータルとして表示します。

構成: upstream の固定タグ `2026.10.0` から `buicha` ブランチを作成し、本体ソースへ直接コミットしています（以前の overlay 方式から移行）。ビルド・デプロイ用のスクリプトやテーマはこの `buicha/` ディレクトリにあります。

## 改変ファイル

| パス | 役割 |
| --- | --- |
| `packages/frontend/src/pages/welcome.entrance.classic.vue` | ログイン前画面（upstream の classic を置き換え） |
| `packages/frontend/src/buicha/services.ts` | ポータルのサービス一覧データ（新規追加） |
| `README.md` | 冒頭にフォークである旨を追記 |
| `buicha/` | ビルド/デプロイスクリプト、テーマ、ドキュメント（新規追加） |

`buicha/` の内訳:

| パス | 役割 |
| --- | --- |
| `build.sh` | ビルド（`BUICHA_REV`, `--no-save`, `--allow-dirty`） |
| `deploy.sh` | イメージの転送・sha256 照合・`docker load` まで（`--dry-run` あり） |
| `.deploy.env.example` | `deploy.sh` の設定例 |
| `compose.override.example.yaml` | compose 設定の例 |
| `themes/buicha-light.json5`, `themes/buicha-dark.json5` | 管理画面で設定するテーマ（イメージには含まれない） |

上流が entrance を classic / simple に分割したため、`classic` をぶいちゃすきーのデザインに差し替えています。管理画面で entrance のスタイルに `simple` を選ぶと、公式のログイン前画面になります。

## 上流との差分の見方

```sh
git diff 2026.10.0..buicha -- packages/
```

GitHub 上: https://github.com/misskey-dev/misskey/compare/2026.10.0...kazunamine:misskeybuichajp:buicha

## 上流

- ソース: https://github.com/misskey-dev/misskey
- ベースタグ: `2026.10.0`

## ライセンス

Misskey は GNU Affero General Public License v3.0 (AGPL-3.0) で公開されており、Copyright © 2014-2025 syuilo and contributors の著作物です。このフォークも同じく AGPL-3.0 で提供します。全文はリポジトリルートの `COPYING` を参照してください。

AGPL-3.0 に基づき、このイメージでネットワーク越しにサービスを提供する場合は、利用者に対応するソース（このフォークの該当コミット）を提供する必要があります。

## ビルド

前提: Docker（buildx 有効）、git、gzip。フロントエンドのビルドが重いため、Docker に 8GB 程度のメモリ割当を推奨します。どのディレクトリから実行しても動きます。

```sh
# 既定（リビジョン 1 / buicha/dist/ に tar.gz を保存）
./buicha/build.sh

# リビジョン指定
BUICHA_REV=2 ./buicha/build.sh

# tar.gz に保存しない（イメージのビルドのみ）
./buicha/build.sh --no-save

# 作業ツリーが dirty でも続行
./buicha/build.sh --allow-dirty
```

処理内容: 事前チェック（docker / buildx / git / gzip）→ 作業ツリーが dirty なら警告して中止 → `git submodule update --init` → リポジトリルートで upstream の `Dockerfile` を使い `linux/amd64` で `docker buildx build`。イメージ名は `buicha/misskey:<ver>-buicha.<rev>`（`<ver>` は `package.json` の version）、成果物は `buicha/dist/misskey-<ver>-buicha.<rev>.tar.gz` です。

## デプロイ（汎用手順）

`deploy.sh` は、ビルド済み tar.gz をサーバーへ scp し、sha256 を照合して `sudo docker load` するところまでを行います。本番 compose の書き換えと `up` は自動では実行せず、完了時に手順を表示します。本番固有の手順はリポジトリ外で管理しています。

1. 設定ファイルを用意する

   ```sh
   cp buicha/.deploy.env.example buicha/.deploy.env
   # TARGET_HOST, TARGET_USER, SSH_PORT, SSH_KEY, BIND_IFACE,
   # REMOTE_COMPOSE_FILES, COMPOSE_PROJECT, COMPOSE_FILE_FOR_UP を編集
   ```

   `buicha/.deploy.env` は gitignore 済みです。`TARGET_HOST` は必須です。

2. 内容確認と実行

   ```sh
   ./buicha/deploy.sh --dry-run buicha/dist/misskey-2026.10.0-buicha.1.tar.gz
   ./buicha/deploy.sh buicha/dist/misskey-2026.10.0-buicha.1.tar.gz
   ```

3. 表示される案内に従い、事前バックアップを取得したうえで compose の `web` の image を `buicha/misskey:<ver>-buicha.<rev>` に変更し、`docker compose up -d --no-deps web` で web のみ切り替える。元の image は必ず控えておく（ロールバック用）。

## サービス一覧の更新方法

1. `packages/frontend/src/buicha/services.ts` を編集してコミット
2. `BUICHA_REV` を上げて再ビルド（例: `BUICHA_REV=2 ./buicha/build.sh`）
3. デプロイ手順で反映

## テーマ

`buicha/themes/buicha-light.json5` / `buicha/themes/buicha-dark.json5` は管理画面（ブランディング / テーマ）に内容を貼り付けて登録・適用します。再ビルドは不要です。

## アップデート手順（upstream 追従）

```sh
git fetch upstream tag <新tag>
git checkout buicha
git merge <新tag>
```

1. コンフリクトを解消する。特に `packages/frontend/src/pages/welcome.entrance.classic.vue` に注意する（`simple.vue` は上流のまま）
2. 上流のリリースノート（マイグレーション有無）を確認する
3. `BUICHA_REV` を 1 に戻して `./buicha/build.sh` でビルドする
4. DB バックアップのうえデプロイする
