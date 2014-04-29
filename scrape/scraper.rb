require "open-uri"
require "nokogiri"

# Retrieve main collection page with list
def object_url_list(baseurl)
  object_url_list = []
  raw_html = open(baseurl, :read_timeout => 60)
  parsed_html = Nokogiri::HTML(raw_html)

  # Get all object works elements and return them as an array of urls
  parsed_html.css(".oe-drawer-list li").each do |link|
    url = link.at("a @href").to_s
    # Only get list of objects
    if url.include?("art-object-page")
      object_url_list << url
    end
  end

  puts "#{object_url_list.count} objects to download."

  # Discard first result for "all paintings"
  object_url_list.slice!(0)

  return object_url_list
end

# Download all html to a file for later parsing
def download_content(object_url, filename)
  raw_html = open(object_url, :read_timeout => 60)
  puts object_url
  puts filename
  File.open(filename, "w") { |file| file.write(raw_html) }
end
