# app/services/api_fetcher.rb

require 'uri'
require 'net/http'
require 'nokogiri'
require 'json'

class BookSearch
  CARIL_API_URL = "https://api.carel.jp/v1/books"
  OPENBD_API_URL = "https://api.openbd.jp/v1/get"

  def self.fetch_data(search_term, search_type = :title)
    # 検索タイプに応じてクエリパラメータを設定
    query_param = search_type == :author ? { author: search_term } : { title: search_term }
    
    # カーリルAPIを使用してデータを取得
    uri = URI(CARIL_API_URL)
    uri.query = URI.encode_www_form(query_param)
    response = Net::HTTP.get(uri)
    books_data = JSON.parse(response)

    # 書籍情報を取得
    books = books_data.map do |book_info|
      isbn = book_info['isbn']
      {
        title: book_info['title'],
        author: book_info['author'],
        publisher: book_info['publisher'],
        isbn: isbn,
        image_link: fetch_cover_image(isbn)
      }
    end

    # ISBNが存在する書籍のみを返す
    books.select { |book| book[:isbn] }.sort_by { |book| book[:title] }
  end

  def self.fetch_cover_image(isbn)
    # openBD APIを使用してカバー画像を取得
    uri = URI("#{OPENBD_API_URL}?isbn=#{isbn}")
    response = Net::HTTP.get_response(uri)
    return nil unless response.is_a?(Net::HTTPSuccess)

    books_data = JSON.parse(response.body)
    book_info = books_data.first
    book_info ? book_info['cover'] : nil
  end
end
