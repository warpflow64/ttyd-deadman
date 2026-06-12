FROM ubuntu:24.04

# 基本ツール + ttyd + tmux + ping
RUN apt-get update && apt-get install -y \
    ttyd \
    tmux \
    python3 \
    iputils-ping \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# deadman バイナリを配置
# 公式リリースがある場合は以下のように取得する
# ARG DEADMAN_VERSION=vX.Y.Z
# RUN curl -L https://github.com/<org>/deadman/releases/download/${DEADMAN_VERSION}/deadman_linux_amd64 \
#     -o /usr/local/bin/deadman && chmod +x /usr/local/bin/deadman

# ローカルビルド済みバイナリを使う場合
COPY deadman /usr/local/bin/deadman
RUN chmod +x /usr/local/bin/deadman

# deadman の設定ファイル
COPY deadman.conf /etc/deadman/deadman.conf

# エントリポイント
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# ttyd のデフォルトポート
EXPOSE 7681

ENTRYPOINT ["/entrypoint.sh"]
