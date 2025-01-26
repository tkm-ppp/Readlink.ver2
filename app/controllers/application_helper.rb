module ApplicationHelper
    def google_book_thumbnail(google_book)
        google_book["volumeInfo"]["imageLinks"].nil? ? "sample.jpg" : google_book["volumeInfo"]["imageLinks"]["thumbnail"]
      end

      # thumbnailはネストしている配置となっているのでdigを使って取り出す
      # また画像のリンクがhttpとなっているためgsubを使いhttpsに変更する。変更した値をbookImageに代入する
      def set_google_book_params(google_book)
        google_book["volumeInfo"]["bookImage"] = google_book.dig("volumeInfo", "imageLinks", "thumbnail")&.gsub("http", "https")

        # ISBNは13桁と10桁があり、どちら1つを取得できればよいので、最初に検索した値をsystemidに代入する
        if google_book["volumeInfo"]["industryIdentifiers"]&.select { |h| h["type"].include?("ISBN") }.present?
          google_book["volumeInfo"]["systemid"] = google_book["volumeInfo"]["industryIdentifiers"]&.select { |h| h["type"].include?("ISBN") }.first["identifier"]
        end
        # volumeInfoの中が必要な項目のみになるようsliceを使って絞りこむ
        google_book["volumeInfo"].slice("title", "authors", "publishedDate", "infoLink", "bookImage", "systemid", "canonicalVolumeLink")
      end
end
