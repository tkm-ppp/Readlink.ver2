require 'net/http'
require 'json'

class RegionsController < ApplicationController
  def index
    @regions_data = {}
    regions_jp = {
      "東北": ["北海道", "青森県", "岩手県", "宮城県", "秋田県", "山形県", "福島県"],
      "関東": ["茨城県", "栃木県", "群馬県", "埼玉県", "千葉県", "東京都", "神奈川県"],
      "中部": ["新潟県", "長野県", "山梨県", "富山県", "石川県", "福井県"],
      "東海": ["岐阜県", "三重県", "静岡県", "愛知県"],
      "近畿": ["大阪府", "京都府", "滋賀県", "兵庫県", "奈良県", "和歌山県"],
      "中国": ["鳥取県", "島根県", "岡山県", "広島県", "山口県"],
      "四国": ["愛媛県", "高知県", "香川県", "徳島県"],
      "九州": ["福岡県", "佐賀県", "長崎県", "大分県", "熊本県", "宮崎県", "鹿児島県", "沖縄県"]
    }

    regions_jp.each do |region_name, prefectures|
      @regions_data[region_name] = {}
      prefectures.each do |pref|
        @regions_data[region_name][pref] =  pref 
      end
    end
  end

  def show
    @pref_name = params[:pref_name]
    @city_library_counts = fetch_city_library_counts(@pref_name)
    @city_library_lists = fetch_all_libraries_in_pref(@pref_name)
  end

  private

  def fetch_library_count(pref)
    endpoint = "https://api.calil.jp/library"
    params = {
      appkey: ENV['CALIL_API_KEY'],
      pref: pref,
      format: "json",
      limit: "1"
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
        return libraries_data.first["total"].to_i rescue 0
      else
        return 0
      end
    rescue JSON::ParserError => e
      Rails.logger.error("JSONの解析エラー: #{e.message} - 県: #{pref}")
      return 0
    end
  end
   def fetch_city_library_counts(pref_name)
    endpoint = "https://api.calil.jp/library"
    city_library_counts = {}

    cities = PrefectureCities::PREFECTURE_CITIES[pref_name]

    cities.each do |city_name|
      params = {
        appkey: ENV['CALIL_API_KEY'],
        pref: pref_name,
        city: city_name,
        format: "json",
        limit: "1"
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
           count = libraries_data.first["total"].to_i rescue 0
           city_library_counts[city_name] = count if count > 0
         end
      rescue JSON::ParserError => e
        Rails.logger.error("JSONの解析エラー: #{e.message} - 県: #{pref_name}, 市町村: #{city_name}")
      end
    end

    city_library_counts
  end

  def fetch_all_libraries_in_pref(pref_name)
    endpoint = "https://api.calil.jp/library"
    all_libraries = {}

    cities = PrefectureCities::PREFECTURE_CITIES[pref_name]

    cities.each do |city_name|
      libraries_in_city = []
      params = {
        appkey: ENV['CALIL_API_KEY'],
        pref: pref_name,
        city: city_name,
        format: "json",
        limit: "100"
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
          libraries_in_city = libraries_data
        end
      rescue JSON::ParserError => e
        Rails.logger.error("JSONの解析エラー: #{e.message} - 県: #{pref_name}, 市町村: #{city_name}")
      end
      all_libraries[city_name] = libraries_in_city if libraries_in_city.present?
    end
    all_libraries
  end
end