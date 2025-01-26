require 'net/http'
require 'json'

endpoint = "https://api.calil.jp/library"

params = {
  appkey: "7c854f40b6a4274618da08219f6c60e0",
  pref: "東京都",
  city: "渋谷区",
  format: "json",
  limit: "5"
}

uri = URI(endpoint)
uri.query = URI.encode_www_form(params)

response = Net::HTTP.get(uri)

# レスポンスをUTF-8に変換
response = response.force_encoding('UTF-8')

puts response  # レスポンスを表示して確認

# JSONP形式のレスポンスの場合、コールバックを削除
if response.start_with?('callback(')
  rjson = response.sub(/^callback\((.*)\);$/, '{\1}')
else
  rjson = response  # そのままレスポンスを使用
end

# JSONをパース
begin
  data = JSON.parse(rjson)
rescue JSON::ParserError => e
  puts "JSONの解析エラー: #{e.message}"
  puts "レスポンス: #{response}"
  exit 1
end

# データを出力
if data.is_a?(Array)  # dataが配列であることを確認
  data.each do |library|
    puts library["formal"]
    puts library["url_pc"]
    puts library["address"]
    puts "----------------------"
  end
else
  puts "データが配列ではありません: #{data.inspect}"
end
