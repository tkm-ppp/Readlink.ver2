class BooksController < ApplicationController
  def search
    if params[:search_term].present?
      @books = ApiFetcher.fetch_data(params[:search_term])
      if @books.present?
        @books = @books.uniq { |book| book[:title] }.sort_by { |book| book[:title] }
        @books = Kaminari.paginate_array(@books).page(params[:page]).per(20)
      else
        @books = Kaminari.paginate_array([]).page(params[:page]).per(20)
      end
      
      csv_filename = Rails.root.join('tmp', "search_results_#{Time.now.to_i}.csv")
      DataProcessor.save_to_csv(@books, csv_filename)
      
      @books = Kaminari.paginate_array(DataProcessor.read_from_csv(csv_filename)).page(params[:page]).per(20)
    else
      @books = Kaminari.paginate_array([]).page(params[:page]).per(20)
    end
  end
end