require 'net/http'
require 'json'

class BookFetcher
  CARIL_API_URL = "https://api.karil.jp/v1/books"
  NDL_API_URL = "https://ndlsearch.ndl.go.jp/api/opensearch"

  def self.fetch_books(search_term)
    # カーリルAPIから書籍情報を取得
    uri = URI("#{CARIL_API_URL}?title=#{URI.encode(search_term)}")
    response = Net::HTTP.get(uri)
    books = JSON.parse(response)

    # NDL APIから詳細情報を取得
    books.each do |book|
      isbn = book['isbn']
      next unless isbn

      ndl_uri = URI("#{NDL_API_URL}?title=#{URI.encode(book['title'])}&isbn=#{isbn}")
      ndl_response = Net::HTTP.get(ndl_uri)
      ndl_data = JSON.parse(ndl_response)

      # NDLのデータをマージ
      book.merge!(ndl_data)
    end

    books
  end
end 