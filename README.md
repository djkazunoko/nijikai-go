# 2次会GO!
テックイベント後の2次会参加者を簡単に募集できるアプリです。

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
### 1. セットアップとサーバーの起動
以下の手順でアプリケーションをセットアップし、サーバーを起動します。

```bash
$ git clone https://github.com/djkazunoko/nijikai-go.git
$ cd nijikai-go
$ EDITOR="code --wait" bin/rails credentials:edit #「2. 環境変数の設定」を行う
$ bin/setup
$ bin/dev
$ open http://localhost:3000/
```

### 2. 環境変数の設定
GitHubのOAuthアプリの登録と`Client ID`、`Client secrets`の設定を行います。

1. GitHubでOAuthアプリを登録し、`Client ID`と`Client secrets`を取得します。  
1. 取得した`Client ID`と`Client secrets`を `config/credentials.yml.enc` に設定します。

詳細な手順については、[PR #67](https://github.com/djkazunoko/nijikai-go/pull/67#issue-2221954700) の「**動作確認方法**」>「**1. 事前準備**」セクションを参照してください。

## 技術スタック
https://github.com/djkazunoko/nijikai-go/wiki/Technology-Stack

## Lint
```
$ bin/lint
```

## テスト
```
$ bundle exec rspec
```
