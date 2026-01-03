# WinApps 手動セットアップ手順

NixOS 設定適用後に行う手動作業の手順書です。

---

## 前提条件

- NixOS 設定が適用済み (`sudo nixos-rebuild switch --flake .#nixos`)
- 再起動済み（カーネルモジュールとグループ変更の反映）

---

## Step 1: WinApps 設定ファイル作成

```bash
mkdir -p ~/.config/winapps

cat > ~/.config/winapps/winapps.conf << 'EOF'
# Backend
WAFLAVOR="podman"

# Windows credentials（Windows側の設定に合わせて変更）
RDP_USER="YourWindowsUsername"
RDP_PASS="YourWindowsPassword"
RDP_IP="127.0.0.1"
EOF

chmod 600 ~/.config/winapps/winapps.conf
```

---

## Step 2: compose.yaml のダウンロードと編集

```bash
curl -o ~/.config/winapps/compose.yaml \
  https://raw.githubusercontent.com/winapps-org/winapps/main/compose.yaml
```

`~/.config/winapps/compose.yaml` を編集:

| 項目 | 説明 | 例 |
|------|------|-----|
| `RAM_SIZE` | VM に割り当てるメモリ | `"4G"` |
| `CPU_CORES` | VM に割り当てるCPUコア数 | `"4"` |
| `VERSION` | Windows バージョン | `"win11"` または `"win10"` |

### Podman rootless 用設定

以下の行をアンコメント（`#` を削除）:

```yaml
group_add:
  - keep-groups
```

---

## Step 3: Windows VM の起動

```bash
podman-compose --file ~/.config/winapps/compose.yaml up
```

VNC でアクセスして Windows をインストール:
- URL: `http://127.0.0.1:8006`

---

## Step 4: Windows VM 側の設定

### 4.1 リモートデスクトップを有効化

**方法 A: 設定アプリから**
```
設定 → システム → リモートデスクトップ → リモートデスクトップを有効にする → オン
```

**方法 B: システムプロパティから**
```
Win + R → sysdm.cpl → Enter
「リモート」タブ → 「このコンピューターへのリモート接続を許可する」にチェック
```

### 4.2 ユーザーアカウント設定

1. パスワードを設定（パスワードなしのアカウントは RDP 接続不可）
2. `winapps.conf` の `RDP_USER` と `RDP_PASS` を Windows のユーザー名・パスワードに合わせる

### 4.3 ネットワークレベル認証 (NLA) の無効化（推奨）

```
Win + R → gpedit.msc → Enter

コンピューターの構成
  → 管理用テンプレート
    → Windows コンポーネント
      → リモート デスクトップ サービス
        → リモート デスクトップ セッション ホスト
          → セキュリティ

「ネットワーク レベル認証を使用したリモート接続にユーザー認証を必要とする」
→ 無効 → OK
```

> **Note:** Windows Home エディションには `gpedit.msc` がありません。レジストリで設定するか、Pro/Enterprise をインストールしてください。

### 4.4 ファイアウォール確認

リモートデスクトップがファイアウォールで許可されていることを確認:
```
コントロールパネル → Windows Defender ファイアウォール
  → アプリにファイアウォール経由の通信を許可
    → 「リモート デスクトップ」にチェック
```

### 4.5 必要なアプリケーションをインストール

使用したい Windows アプリケーションをインストールします。

---

## Step 5: 接続確認（Linux 側）

FreeRDP で接続テスト:

```bash
xfreerdp3 /u:YourWindowsUsername /p:YourWindowsPassword /v:127.0.0.1:3389
```

成功すると Windows デスクトップが表示されます。

### トラブルシューティング

| エラー | 対処法 |
|--------|--------|
| 接続拒否 | Windows でリモートデスクトップが有効か確認 |
| 認証失敗 | ユーザー名・パスワードを確認、NLA を無効化 |
| ポート接続不可 | VM が起動しているか確認 (`podman ps`) |

---

## Step 6: WinApps 初期化

```bash
winapps --setup
```

これにより:
- Windows 上のインストール済みアプリを検出
- KDE アプリメニューにショートカットを作成
- MIME タイプの関連付けを設定

---

## 日常的な使用

### VM の起動

```bash
podman-compose --file ~/.config/winapps/compose.yaml start
```

### VM の停止

```bash
podman-compose --file ~/.config/winapps/compose.yaml stop
```

### VM の一時停止/再開

```bash
podman-compose --file ~/.config/winapps/compose.yaml pause
podman-compose --file ~/.config/winapps/compose.yaml unpause
```

### アプリの再スキャン

新しいアプリをインストールした後:
```bash
winapps --setup
```

---

## ファイル共有

Linux の `/home` ディレクトリは Windows から以下のパスでアクセス可能:
```
\\tsclient\home
```

エクスプローラーのアドレスバーに入力してアクセスできます。

---

## 参考リンク

- [WinApps GitHub](https://github.com/winapps-org/winapps)
- [WinApps Docker/Podman ドキュメント](https://github.com/winapps-org/winapps/blob/main/docs/docker.md)
