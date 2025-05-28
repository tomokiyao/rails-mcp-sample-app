# ベースイメージを指定
FROM ruby:3.2.2

# 最初に logger gem をインストール
RUN gem install logger --default

# 必要なパッケージをインストール (Node.js, Yarn, PostgreSQLクライアントなど)
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs yarn

# 作業ディレクトリを作成
WORKDIR /app

# Gemfileをコンテナにコピー
COPY Gemfile Gemfile.lock ./

# BundlerでGemをインストール
RUN bundle install

# ポートを開放
EXPOSE 3000
