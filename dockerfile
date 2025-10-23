# Dockerfile for Development
FROM ruby:3.3-slim

# 必要なパッケージをインストール（libyaml-devを追加）
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    libyaml-dev \
    curl \
    git \
    pkg-config \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# 作業ディレクトリ
WORKDIR /app

# bundlerを最新化
RUN gem update --system && gem install bundler

# 環境変数設定
ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_BIN=/usr/local/bundle/bin \
    GEM_HOME=/usr/local/bundle \
    RAILS_ENV=development

# Entrypointスクリプトをコピー
COPY --chmod=755 docker/entrypoint.sh /usr/local/bin/app-entrypoint

ENTRYPOINT ["/usr/local/bin/app-entrypoint"]
CMD ["bash", "-lc", "bin/rails server -b 0.0.0.0 -p 3000"]
