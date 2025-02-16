# 2次会GO！
## 概要
2次会GO！は、テック系イベントの二次会参加者を簡単に集めることができる、二次会参加者募集ツールです。
- チェックボックスを選択するだけで、必要な情報が過不足なく載っている二次会参加者募集ページを簡単に作成できます。
- 作成した二次会参加者募集ページのURLを、今参加しているイベントのハッシュタグを付けてXに投稿することで、二次会参加者を募集できます。
- 参加者とそのページから直接連絡を取り合う機能が備わっているため、参加者同士のコミュニケーションがスムーズに行えます。

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

### 3. Redisのインストールと起動
Turbo StreamsでAction Cableを使用する際にRedisが必要です。

以下の手順でRedisをインストールし、起動します。

```bash
# macOSの場合
$ brew install redis
$ brew services start redis
```

## Lint
```
$ bin/lint
```

## テスト
```
$ bundle exec rspec
```
