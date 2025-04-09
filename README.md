# 2次会GO!
テックイベントの2次会参加者募集ツール。

## URL
https://nijikai-go.fly.dev/

## できること

### 2次会参加者募集ページの作成
いくつかの質問に答えるだけで、必要な情報が過不足なく載っている2次会参加者募集ページを簡単に作成できます。

### Xでの2次会参加者の募集
作成した2次会参加者募集ページをX(旧Twitter)で共有して2次会参加者を募集できます。

### 2次会参加者との連絡
2次会参加者募集ページ上で参加者と直接連絡を取り合うことができます。

## ローカルでの環境構築手順
### 1. アプリケーションのセットアップ
以下のコマンドを実行してアプリケーションのセットアップを行います。
```bash
$ git clone https://github.com/djkazunoko/nijikai-go.git
$ cd nijikai-go
$ bin/setup
```

### 2. 環境変数の設定
GitHubでのOAuthアプリの作成と、アプリケーションへの`Client ID`と`Client secrets`の設定を行います。

#### 2-1. OAuthアプリを作成
[OAuth アプリの作成 - GitHub Docs](https://docs.github.com/ja/apps/oauth-apps/building-oauth-apps/creating-an-oauth-app) を手順を参考にOAuthアプリを作成します。

フォームの各項目には以下の値を入力していください。

- Application name
  - `nijikai-go-dev`
- Homepage URL
  - `http://localhost:3000/`
- Authorization callback URL
  - `http://localhost:3000/auth/github/callback`

取得した`Client ID`と`Client secrets`の値をメモします。

#### 2-2. Client IDとClient secretsを暗号化して保存
以下のコマンドを実行して`config/credentials/development.yml.enc`の作成・編集を行います。
```
$ EDITOR="code --wait" bin/rails credentials:edit -e development
```

`config/credentials/development.yml.enc`に前項で取得した`Client ID`と`Client secrets`の値を追加して保存します。
```
github:
  client_id: "<Client ID>"
  client_secret: "<Client secrets>"
```

- 参考: [PR #67](https://github.com/djkazunoko/nijikai-go/pull/67)

### 3. サーバーの起動
以下のコマンドを実行してサーバーを起動します。
```
$ bin/dev
```

ブラウザから http://localhost:3000/ にアクセスします。


## 技術スタック
https://github.com/djkazunoko/nijikai-go/wiki/Technology-Stack

## Lint
```
$ bin/lint
```

## テスト
以下のコマンドを実行して`config/credentials/test.yml.enc`の作成・編集を行います。
```
$ EDITOR="code --wait" bin/rails credentials:edit -e test
```

`config/credentials/test.yml.enc`に「2-1. OAuthアプリを作成」で取得した`Client ID`と`Client secrets`の値を追加して保存します。
```
github:
  client_id: "<Client ID>"
  client_secret: "<Client secrets>"
```

以下のコマンドを実行してテストを実行します。
```
$ bundle exec rspec
```
