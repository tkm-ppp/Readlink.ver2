require 'net/http'
require 'json'
require 'csv'
require_relative '../services/book_fetcher'
require_relative '../services/data_processor'

class BooksController < ApplicationController
  def search
    @books = []
    if params[:search_term].present?
      begin
        Rails.logger.info("検索ワード: #{params[:search_term]}") # 検索ワードのログ
        @books = BookFetcher.fetch_books_by_query(params[:search_term])
        if @books.empty?
          flash.now[:alert] = "該当する書籍は見つかりませんでした。"
          Rails.logger.info("検索結果: 該当する書籍は見つかりませんでした。")
        else
          Rails.logger.info("検索結果: #{@books.count}件の書籍が見つかりました。")
          Rails.logger.debug("検索結果: #{@books.inspect}") # より詳細なログ(debugレベル)
         end
      rescue => e
        flash.now[:alert] = "書籍データの取得中にエラーが発生しました: #{e.message}"
        Rails.logger.error("書籍データの取得中にエラーが発生しました: #{e.message}")
      end
    end
  end

  def show
    @book = nil
    begin
      books = DataProcessor.read_from_csv
      isbn = params[:isbn]
      @book = books.find { |book| book['ISBN'] == isbn }
       if @book.nil?
         flash.now[:alert] = "指定された書籍が見つかりませんでした。"
         Rails.logger.info("書籍詳細: ISBN #{isbn} の書籍は見つかりませんでした。")
        else
         Rails.logger.info("書籍詳細: ISBN #{isbn} の書籍情報を表示します。")
         Rails.logger.debug("書籍詳細: #{@book.inspect}")
       end
    rescue => e
      flash.now[:alert] = "CSVファイルの読み込み中にエラーが発生しました: #{e.message}"
       Rails.logger.error("CSVファイルの読み込み中にエラーが発生しました: #{e.message}")
    end
  end
end