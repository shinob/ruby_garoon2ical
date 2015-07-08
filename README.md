# ruby_garoon2ical

Export 3 months schedule from Cybozu Garoon 3 as iCal data by Ruby script.

## 機能

サイボウズ社のグループウェア「Garoon 3」からダウンロードできるiCalデータを3ヶ月分結合したデータを取り出します。

## 使い方

スクリプト内にあるパラメータを利用する環境にあわせて書き換えます。

loginURL = ''

users = [
  {
    "name" => "",
    "uid" => "",
    "gid" => ""
  },
  {
    "name" => "",
    "uid" => "",
    "gid" => ""
  }
]

書き換えた後、以下のコマンドを実行します。

$ ruby garoon2ical.rb
