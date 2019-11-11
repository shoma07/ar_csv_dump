# AR CSV Dump

- ActiveRecordでDBのバックアップをCSVで取得する
- 取得したCSVからデータをインポートする
- db/dump/<timestamp>/ 以下に出力

## Usage

```
$ bin/rails r path/ar_csv_dump.rb
# 特定のテーブル
$ bin/rails r path/ar_csv_dump.rb --table table1,table2
```

## Author

@shoma07
