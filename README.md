# deadman-ttyd

deadman を ttyd 経由でブラウザから閲覧専用で配信する Docker 構成です。
NOC部屋のサーバで動かし、会場スタッフがスマホ・ノートPCのブラウザから状態を確認できます。

## 構成

```
[deadman] → tmux セッション内で起動
    ↓
[ttyd]    → read-only でブラウザに配信
    ↓
http://localhost:7681 でスタッフが閲覧
```

## 使い方

### 1. deadman バイナリを配置

```bash
# ビルド済みバイナリをこのディレクトリに置く
cp /path/to/deadman ./deadman
```

### 2. deadman の設定ファイルを用意

```bash
cp /path/to/your/deadman.yaml ./deadman.yaml
```

### 3. 起動

```bash
docker compose up -d
```

### 4. アクセス確認

```
http://localhost:7681
```

## 注意点

### ping に NET_RAW が必要
ICMP (ping) は Docker コンテナ内では `CAP_NET_RAW` が必要です。
docker-compose.yml に `cap_add: [NET_RAW]` が入っています。

セキュリティポリシー上 cap_add が使えない環境では:
- `network_mode: host` に切り替える
- ping の代わりに TCP/QUIC での監視にする

### 管理ネットワーク外には公開しない
ttyd は HTTP で配信されるため、NOC用の管理 VLAN 内からのみアクセスできるように
ファイアウォールまたは nginx のアクセス制限を入れることを推奨します。

```nginx
# nginx での例
location / {
    proxy_pass http://localhost:7681;
    allow 192.168.0.0/24;  # NOC セグメントのみ
    deny all;
}
```

### Basic認証をかける場合

docker-compose.yml の環境変数を有効にします:

```yaml
environment:
  TTYD_CREDENTIAL: "noc:yourpassword"
```

## サイネージ用途（会場モニター）

Raspberry Pi + Chromium でキオスク表示する場合:

```bash
chromium-browser \
  --kiosk \
  --noerrdialogs \
  --disable-infobars \
  "http://localhost:7681"
```
