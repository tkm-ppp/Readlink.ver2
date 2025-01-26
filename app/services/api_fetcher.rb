# app/services/api_fetcher.rb

require 'uri'
require 'net/http'
require 'nokogiri'

class ApiFetcher
  OPENSEARCH_API_URL = "https://ndlsearch.ndl.go.jp/api/opensearch"
  COVER_API_BASE_URL = "https://ndlsearch.ndl.go.jp/thumbnail"

  def self.fetch_data(search_term)
    uri = URI(OPENSEARCH_API_URL)
    uri.query = URI.encode_www_form(
      title: search_term,
      
    )
    response = Net::HTTP.get(uri)
    
    doc = Nokogiri::XML(response)
    
    doc.xpath('/rss/channel/item').map do |item|
      {
        title: item.at_xpath('title')&.content,
        author: item.at_xpath('author')&.content,
        publisher: item.at_xpath('dc:publisher')&.content,
        info_link: item.at_xpath('link')&.content,
        published_date: item.at_xpath('dc:date')&.content,
        isbn: item.at_xpath('dc:identifier')&.content&.gsub('ISBN:', ''),
        image_link: "#{COVER_API_BASE_URL}/#{item.at_xpath('dc:identifier')&.content&.gsub('ISBN:', '')}"
      }
    end
  end
end
