#!/bin/bash
set -euo pipefail

# 初回のみ rails new（コンテナ内のRails 8.1を明示指定）
if [ ! -f "bin/rails" ]; then
  echo "[entrypoint] Generating Rails 8.1 API app in container ..."
  gem install rails -v '~> 8.1.0' --no-document
  rails new . --api --database=postgresql --skip-javascript --skip-hotwire \
    --skip-action-mailbox --skip-action-text --skip-active-storage --skip-system-test --force
  bundle config set path "$BUNDLE_PATH"
  bundle install
fi

# 依存関係を確認してインストール
if [ -f "Gemfile" ]; then
  echo "[entrypoint] Installing dependencies ..."
  bundle check || bundle install
fi

echo "[entrypoint] Waiting for DB ..."
for i in $(seq 1 60); do
  if pg_isready -q -h db -p 5432 -U postgres; then
    break
  fi
  sleep 1
done

echo "[entrypoint] Preparing database ..."
bundle exec rails db:prepare

exec "$@"
