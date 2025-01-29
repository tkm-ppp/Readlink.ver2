require 'csv'

class DataProcessor
  def self.read_from_csv(filename = 'books.csv')
     begin
       CSV.read(filename, headers: true).map(&:to_h)
      rescue Errno::ENOENT => e
        Rails.logger.error("CSVファイルが見つかりません: #{e.message}")
       []
      rescue CSV::MalformedCSVError => e
        Rails.logger.error("CSVファイルが不正です: #{e.message}")
        []
     end
  end
   def self.save_to_csv(books, filename = 'books.csv', mode: 'w', col_sep: ',')
    begin
       CSV.open(filename, mode, col_sep: col_sep) do |csv|
          csv << ['ISBN', 'Title', 'Author', 'Publisher', 'Cover URL']
          books.each do |book|
             csv << [book['isbn'], book['title'], book['author'], book['publisher'], book['cover_url']]
         end
       end
     rescue => e
      Rails.logger.error("CSVファイルの保存中にエラーが発生しました: #{e.message}")
   end
  end
end