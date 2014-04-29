require "open-uri"
require "nokogiri"

# Retrieve main collection page with list
def object_url_list(baseurl)
  object_url_list = []
  raw_html = open(baseurl, :read_timeout => 60)
  parsed_html = Nokogiri::HTML(raw_html)

  # Get all object works elements and return them as an array of urls
  parsed_html.css(".oe-drawer-list li").each do |link|
    object_url_list << link.at("a @href")
  end

  return object_url_list
end

# Download all html to a file for later parsing
def download_content(url)

end
