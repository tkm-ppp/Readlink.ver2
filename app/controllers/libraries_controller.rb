require 'net/http'
require 'json'

class LibrariesController < ApplicationController
  def show
    @library_id = params[:library_id] # 図書館IDをパラメータから取得
    @library_detail = fetch_library_detail(@library_id) # 図書館詳細情報を取得

    if @library_detail.nil?
      flash.now[:alert] = "図書館情報が見つかりませんでした。" 
    end
  end

  private

  def fetch_library_detail(library_id) # 図書館詳細情報を取得するメソッド
    endpoint = "https://api.calil.jp/library"
    params = {
      appkey: "	7c854f40b6a4274618da08219f6c60e0",
      libid: library_id, 
      format: "json",
    }

    uri = URI(endpoint)
    uri.query = URI.encode_www_form(params)

    response = Net::HTTP.get(uri)
    response = response.force_encoding('UTF-8')

    if response.start_with?('callback(') && response.end_with?(');')
      rjson = response.delete_prefix('callback(').delete_suffix(');')
    else
      rjson = response
    end

    begin
      libraries_data = JSON.parse(rjson)
      if libraries_data.is_a?(Array) && libraries_data.any?
        return libraries_data.first # 詳細情報は配列の最初の要素に入っている
      else
        return nil # データがない場合はnilを返す
      end
    rescue JSON::ParserError => e
      Rails.logger.error("JSONの解析エラー: #{e.message} - 図書館ID: #{library_id}")
      return nil # エラー時はnilを返す
    end
  end
end