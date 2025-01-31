# app/services/library_fetcher.rb
require 'net/http'
require 'json'
require 'rails' # Rails.logger を使用するため

class LibraryFetcher
  CARIL_API_URL = "https://api.calil.jp/check"
  OPENBD_API_URL = "https://api.openbd.jp/v1/get" # openBD API の URL を追加

  # 既存のメソッド (check_availability_in_osaka, format_availability_results) はそのまま

  def self.fetch_book_detail_from_openbd(isbn) # openBD API から書籍詳細情報を取得するメソッド
    uri = URI("#{OPENBD_API_URL}?isbn=#{isbn}")

    begin
      response = Net::HTTP.get_response(uri)

      unless response.is_a?(Net::HTTPSuccess)
        Rails.logger.error "OpenBD API Error Response: #{response.code} #{response.message}"
        Rails.logger.error "Response Body: #{response.body}"
        return nil # エラー時は nil を返す
      end

      json_response = response.body
      books_data = JSON.parse(json_response)

      # openBD API は ISBN に該当する書籍が見つからない場合も空配列を返すので、nil チェックは不要

      book_info = books_data.first # 配列の最初の要素を取得 (通常は1件のはず)
      return nil if book_info.nil? # 書籍情報が nil の場合は nil を返す

      # 必要な情報を抽出 (openBD API のレスポンス構造に合わせて調整)
      detail = book_info['summary'] || {} # summary が nil の場合を考慮
      cover_url = book_info['cover'] # cover URL を取得

      book = {
        title: detail['title'],
        author: detail['author'],
        publisher: detail['publisher'],
        isbn: detail['isbn'],
        cover_url: cover_url # カバーURLを追加
      }
      book # 書籍情報を返す

    rescue JSON::ParserError => json_error
      Rails.logger.error "OpenBD JSON Parse Error: #{json_error.message}"
      Rails.logger.error "Failed JSON Response Body: #{json_response}"
      nil # JSON パースエラー時は nil を返す

    rescue => e
      Rails.logger.error "Error fetching book detail from OpenBD for ISBN #{isbn}: #{e.message}"
      nil # その他のエラー発生時も nil を返す
    end
  end

  def self.fetch_book_details(isbn) # メソッド名を変更、systemid を固定、appkey を環境変数から取得
    appkey = ENV['CALIL_API_KEY'] # 環境変数からAPIキーを取得
    prefecture_system_ids = [
  'Osaka_Osaka', 'Osaka_Sakai', 'Osaka_Kishiwada', 'Osaka_Toyonaka', 
  'Osaka_Ikeda', 'Osaka_Suita', 'Osaka_IzumiOtsu', 'Osaka_Takatsuki', 
  'Osaka_Kaizuka', 'Osaka_Moriguchi', 'Osaka_Hirakata', 'Osaka_Ibaraki', 
  'Osaka_Yao', 'Osaka_IzumiSano', 'Osaka_Tondabayashi', 'Osaka_Neyagawa', 
  'Osaka_Kawachinagano', 'Osaka_Matsubara', 'Osaka_Daito', 'Osaka_Izumi', 
  'Osaka_Minoh', 'Osaka_Kashiwara', 'Osaka_Habikino', 'Osaka_Kadoma', 
  'Osaka_Setsuto', 'Osaka_Takaishi', 'Osaka_Fujidera', 'Osaka_Higashiosaka', 
  'Osaka_Sennan', 'Osaka_Shirodawate', 'Osaka_Katano', 'Osaka_Osakasayama', 
  'Osaka_Hannan', 'Osaka_Shimamoto', 'Osaka_Toyono', 'Osaka_Nose', 
  'Osaka_Tadaoka', 'Osaka_Kumatori', 'Osaka_Tajiri', 'Osaka_Misaki', 
  'Osaka_Taishi', 'Osaka_Kawachinagano', 'Osaka_Chihayaakasaka'
]


    Rails.logger.debug "APIキー (先頭5文字): #{appkey.to_s[0..4]}... (デバッグのため先頭5文字のみ表示)" if appkey.present? # APIキーが読み込めているか確認 (先頭5文字のみログ出力)

    params = {
      appkey: appkey,
      isbn: isbn,
      systemid: prefecture_system_ids.join(','),
      format: 'json'
    }

    uri = URI(CARIL_API_URL)
    uri.query = URI.encode_www_form(params)

    Rails.logger.debug "Request URL: #{uri.to_s}" # リクエストURLをログ出力

    session = nil # セッションIDを保持する変数

    loop do # continue が 1 の間リトライ
      begin
        # Net::HTTP.get_response を使用するように変更
        response = Net::HTTP.get_response(uri)

        Rails.logger.debug "Response Class: #{response.class.name}" # レスポンスのクラス名をログ出力

        # レスポンスが Net::HTTPResponse オブジェクトであることを確認
        unless response.is_a?(Net::HTTPResponse)
          Rails.logger.error "Unexpected response type: #{response.class.name}"
          Rails.logger.error "Response Body (possibly error message): #{response.body}" if response.respond_to?(:body)
          return { error: "APIリクエストで予期せぬレスポンスを受け取りました" }
        end


        Rails.logger.debug "Response Status Code: #{response.code}" # HTTPステータスコードをログ出力

        # HTTPステータスコードが 2xx (成功) 以外の場合はエラーとする
        unless response.is_a?(Net::HTTPSuccess)
          Rails.logger.error "HTTP Error Response: #{response.code} #{response.message}"
          Rails.logger.error "Response Body: #{response.body}"
          return { error: "APIリクエストエラー: HTTPステータスコード #{response.code}" }
        end


        json_response = response.body
        Rails.logger.debug "Response Body (JSONP before conversion): #{json_response}" # JSONP形式のレスポンスをログ出力

        # JSONP形式からJSON形式に変換 (callback() が付いている場合)
        if json_response.start_with?('callback(') && json_response.end_with?(');')
          json_response = json_response.delete_prefix('callback(').delete_suffix(');')
          Rails.logger.debug "Response Body (JSON after conversion): #{json_response}" # 変換後のJSONをログ出力
        end

        result = JSON.parse(json_response)
        Rails.logger.debug "Parsed JSON Result: #{result.inspect}" # パース後のJSON結果をログ出力

        if result['continue'] == 1
          session = result['session'] # セッションIDを取得
          Rails.logger.debug "Continue flag is 1. Session ID: #{session}" # セッションIDをログ出力
          sleep 1 # 1秒待機 (APIの推奨に従う)
          # 2回目以降のリクエストは session ID を付与
          params_with_session = {
            appkey: appkey,
            session: session,
            format: 'json'
          }
          uri.query = URI.encode_www_form(params_with_session) # URIを更新
          Rails.logger.debug "Retry Request URL (with session): #{uri.to_s}" # リトライ時のリクエストURLをログ出力
          next # ループを継続
        else
          Rails.logger.debug "Continue flag is 0. Final Result processing." # continue=0 の場合のログ
          return format_availability_results(result) # 結果を整形して返す
        end

      rescue JSON::ParserError => json_error
        Rails.logger.error "JSON Parse Error: #{json_error.message}" # JSONパースエラーをログ出力
        Rails.logger.error "Failed JSON Response Body: #{json_response}" # パースに失敗したJSONレスポンスをログ出力
        return { error: "レスポンスのJSONパースに失敗しました" } # JSONパースエラーの情報を返す

      rescue => e
        Rails.logger.error "Error checking availability for ISBN #{isbn}: #{e.message}" # その他のエラーをログ出力
        return { error: "在庫状況の確認に失敗しました: #{e.message}" } # エラー情報を返す
      end
    end
  end

  def self.format_availability_results(result) # 結果を整形するメソッド
    formatted_results = {} # 返却するハッシュ

    if result['books'] && result['books'].key?(result['books'].keys.first) # ISBNでキーアクセスするように修正
      isbn = result['books'].keys.first # ISBNを取得
      library_info = result['books'][isbn]
      formatted_results[isbn] = {}

      library_info.each do |systemid, details| # systemid のループ
        formatted_results[isbn][systemid] = { # systemid をキーにする
          status: details['status'],
          reserveurl: details['reserveurl'],
          libraries: {} # libraries をハッシュで初期化
        }
        if details['libkey']
          details['libkey'].each do |lib_name, status|
            formatted_results[isbn][systemid][:libraries][lib_name] = status # 図書館名をキー、状態を値
          end
        end
      end
    else
      formatted_results = { error: "書籍情報が見つかりませんでした。" }
    end
    Rails.logger.debug "Formatted Results: #{formatted_results.inspect}" # 整形後の結果をログ出力
    formatted_results
  end
end