require "nokogiri"
require "yaml"

$genres = YAML.load_file("scrape/genres.yaml")

def import_objects(filelist)
  filelist.each do |path|
    object_hash = parse_file(path)
    DATABASE.insert(object_hash)
  end
end

# If any elements are empty, write "nil"
class NilClass
  def content()
    return nil
  end
end

def get_genre(accession)
  if $genres.key?(accession)
    return $genres[accession]
  else 
    return nil
  end
end

def parse_file(path)
  # Load and parse HTML
  raw_html = File.read(path)
  parsed_html = Nokogiri::HTML(raw_html)

  object_data = {}

  # Store key fields from HTML



  ##### artist details #####

  # artist

  artist = parsed_html.at_css(".artist-details .artist").content
  object_data[:artist] = artist

  # nationality (incl. birth/death dates)
  nationality = parsed_html.at_css(".artist-details .nationality").content
  object_data[:nationality] = nationality


  ##### artork details #####

  # title
  title = parsed_html.at_css(".artwork-details .title").content
  object_data[:title] = title

  # created
  created = parsed_html.at_css(".artwork-details .created").content
  object_data[:created] = created

  # medium

  medium = parsed_html.at_css(".artwork-details .medium").content
  object_data[:medium] = medium

  # dimensions
  dimensions = parsed_html.at_css(".artwork-details .dimensions").content
  object_data[:dimensions] = dimensions

  # credit

  credit = parsed_html.at_css(".artwork-details .credit").content
  object_data[:credit] = credit

  # accession

  accession = parsed_html.at_css(".artwork-details .accession").content
  object_data[:accession] = accession

  # onview

  onview = parsed_html.at_css(".artwork-details .onview").content
  if onview == "On View"
    object_data[:onview] = true
    location = parsed_html.at_css(".artwork-details .onview @href").to_s
    object_data[:location] = location
  else
    object_data[:onview] = false
    object_data[:location] = nil
  end


  ##### catalog entry #####
  # Uncomment this section if you wish to parse all the catalog texts as well
  #########################
  # overview

  # overview = parsed_html.at_css("#overview").content
  # object_data[:overview] = overview

  # # entry

  # entry = parsed_html.at_css("#entry").content
  # object_data[:entry] = entry

  # # inscription

  # inscription = parsed_html.at_css("#inscription").content
  # object_data[:inscription] = inscription

  # # marks

  # marks = parsed_html.at_css("#marks").content
  # object_data[:marks] = marks

  # # provenance

  # provenance = parsed_html.at_css("#provenance").content
  # object_data[:provenance] = provenance

  # # history

  # history = parsed_html.at_css("#history").content
  # object_data[:history] = history

  # # bibliography

  # bibliography = parsed_html.at_css("#bibliography").content
  # object_data[:bibliography] = bibliography

  # # consvNotes

  # consvNotes = parsed_html.at_css("#consvNotes").content
  # object_data[:consvNotes] = consvNotes

  # Add genre
  object_data[:genre] = get_genre(accession)

  # Return object_data hash
  return object_data
end
