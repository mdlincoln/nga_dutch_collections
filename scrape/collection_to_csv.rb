require "csv"

# From an array of JSON filenames, create a csv file
def collection_to_csv(filepaths, csv_name)
  output_file = CSV.open(csv_name, "w")
  header = JSON.parse!(File.read(filepaths[0])).keys
  output_file << header

  filepaths.each do |path|
    data = JSON.parse!(File.read(path))
    output_file << data.values
  end
end

