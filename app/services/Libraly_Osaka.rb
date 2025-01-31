require 'net/http'
require 'json'
require 'uri'
require 'nokogiri' # XMLを解析するために必要

class LibraryFetcher
  LIBRARY_API_URL = "https://api.calil.jp/library"

  def self.fetch_libraries(pref)
    params = {
      appkey: ENV['CALIL_API_KEY'],
      pref: pref,
      format: 'xml' # デフォルトはxmlなので明示的に指定
    }

    uri = URI(LIBRARY_API_URL)
    uri.query = URI.encode_www_form(params)

    begin
      response = Net::HTTP.get_response(uri)
      puts "リクエストURL: #{uri.to_s}" # リクエストURLを表示

      # HTTPステータスコードが200以外の場合はエラーを返す
      unless response.is_a?(Net::HTTPSuccess)
        puts "APIリクエストエラー: HTTPステータスコード #{response.code}"
        return { error: "APIリクエストエラー: HTTPステータスコード #{response.code}" }
      end

      # XMLを解析
      xml = Nokogiri::XML(response.body)
      libraries = xml.css('library')

      if libraries.empty?
        puts "図書館情報が見つかりませんでした。"
        return { error: "図書館情報が見つかりませんでした。" }
      end

      libraries.map do |library|
        systemid = library.at_css('systemid')
        systemname = library.at_css('systemname')

        if systemid && systemname
          puts "システムID: #{systemid.text}"
          puts "図書館名: #{systemname.text}"
          {
            systemid: systemid.text,
            systemname: systemname.text
          }
        else
          puts "システムIDまたは図書館名が見つかりませんでした。"
          nil
        end
      end.compact # nilを除外
    rescue StandardError => e
      puts "エラーが発生しました: #{e.message}"
      { error: "エラーが発生しました: #{e.message}" }
    end
  end
end

# 使用例
pref = "大阪府"
libraries = LibraryFetcher.fetch_libraries(pref)

if libraries.is_a?(Hash) && libraries.key?(:error)
  puts libraries[:error]
else
  puts "図書館情報の取得に成功しました。"
end
