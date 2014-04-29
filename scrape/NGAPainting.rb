require "nokogiri"
require "mongo"

DATABASE = Mongo::MongoClient.new["arth"]["nga_dutch"]

def import_objects(filelist)
  filelist.each do |path|
    object_hash = parse_file(path)
    DATABASE.insert(object_hash)
end

def parse_file(path)
  # Load and parse HTML
  raw_html = File.read(path)
  parsed_html = Nokogiri::HTML(raw_html)

  object_data = {}

  # Store key fields from HTML

  # Return object_data hash
  return object_data
end
