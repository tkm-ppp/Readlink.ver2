require 'net/http'
require 'json'
require 'csv'
require_relative 'data_processor'

class BookFetcher
  CALIL_API_URL = "https://api.calil.jp/check"
  OPENBD_API_URL = "https://api.openbd.jp/v1/get"
  
  def self.fetch_books_by_query(search_term)
    Rails.logger.info("OpenBDで書籍の検索を開始します: #{search_term}")
    isbns = fetch_isbns_from_openbd(search_term)
    Rails.logger.info("OpenBDからの検索結果: ISBNs = #{isbns.inspect}")
    return [] if isbns.empty?
    Rails.logger.info("カーリルAPIで書籍情報を取得します: ISBNs = #{isbns.inspect}")
    books = fetch_books_from_calil(isbns)
    Rails.logger.info("カーリルAPIからの検索結果: books = #{books.inspect}")
    books = fetch_details_from_openbd(books)
    Rails.logger.info("OpenBD APIから詳細情報を取得: books = #{books.inspect}")
    DataProcessor.save_to_csv(books)
    Rails.logger.info("書籍情報をCSVファイルに保存しました")
    books
  end

  private

  def self.fetch_isbns_from_openbd(search_term)
    Rails.logger.debug("fetch_isbns_from_openbd メソッドを開始: search_term = #{search_term}")
    uri = URI(OPENBD_API_URL)
    params = {
      title: search_term,
      author: search_term
    }
    uri.query = URI.encode_www_form(params)
    Rails.logger.debug("OpenBD APIリクエストURL: #{uri}")
    
    response = Net::HTTP.get(uri)
    Rails.logger.debug("OpenBD APIレスポンス（生）: #{response}")
    
    response = response.force_encoding('UTF-8')
    Rails.logger.debug("OpenBD APIレスポンス（UTF-8エンコード後）: #{response}")
    
    begin
      openbd_data = JSON.parse(response)
      Rails.logger.debug("OpenBD APIレスポンス（JSON解析後）: #{openbd_data.inspect}")
      
      isbns = openbd_data.select { |item| !item.nil? && !item["summary"].nil?}.map { |item| item["summary"]["isbn"]}.compact
      Rails.logger.debug("抽出されたISBN一覧: #{isbns}")
      
      isbns
    rescue JSON::ParserError => e
      Rails.logger.error("OpenBD APIのレスポンス解析に失敗しました: #{e.message}")
      Rails.logger.error("解析に失敗したレスポンス: #{response}")
      []
    end
  end
  

  def self.fetch_books_from_calil(isbns)
    books = []
    isbns.each do |isbn|
      uri = URI(CALIL_API_URL)
      params = {
        appkey: ENV['CALIL_API_KEY'],
        isbn: isbn,
        format: 'json'
      }
      uri.query = URI.encode_www_form(params)
      response = Net::HTTP.get(uri)
      puts response.body  # レスポンスの内容を出力
      response = response.force_encoding('UTF-8')
      if response.start_with?('callback(') && response.end_with?(');')
        rjson = response.delete_prefix('callback(').delete_suffix(');')
      else
        rjson = response
      end
      begin
        calil_data = JSON.parse(rjson)
        if calil_data.is_a?(Array) && !calil_data.empty?
          books << {'isbn' => calil_data.first['isbn']}
          Rails.logger.debug("カーリルAPIのレスポンス: #{calil_data.inspect}")
        end
      rescue JSON::ParserError => e
        Rails.logger.error("JSONの解析エラー: #{e.message}")
      end
    end
    books
  end

  def self.fetch_details_from_openbd(books)
    return [] if books.empty?
    isbns = books.map { |book| book['isbn'] }.join(',')
    uri = URI("#{OPENBD_API_URL}?isbn=#{isbns}")
    response = Net::HTTP.get(uri)
    puts response.body  # レスポンスの内容を出力
    response = response.force_encoding('UTF-8')
    begin
      details = JSON.parse(response)
      books.each_with_index do |book, index|
        book_details = details[index]
        next if book_details.nil? || book_details.empty? || book_details["summary"].nil?
        book['title'] = book_details['summary']['title']
        book['author'] = book_details['summary']['author']
        book['publisher'] = book_details['summary']['publisher']
        book['cover_url'] = book_details['summary']['cover']
      end
    rescue JSON::ParserError => e
      Rails.logger.error("OpenBD APIのレスポンス解析に失敗しました: #{e.message}")
      books.each do |book|
        book['title'] = "情報取得失敗"
        book['author'] = "情報取得失敗"
        book['publisher'] = "情報取得失敗"
        book['cover_url'] = nil
      end
    end
    Rails.logger.debug("OpenBD APIの詳細情報レスポンス: #{details.inspect}")
    books
  end
end
