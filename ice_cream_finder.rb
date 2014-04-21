require 'nokogiri'
require 'addressable/uri'
require 'json'
require 'launchy'
require 'rest-client'


def get_api_key
  api_key = nil
  begin
    api_key = File.read('api_key.rb').chomp
  rescue
    puts "Unable to read 'api_key'. Please provide a valid Google API key."
    exit
  end
end

def input_address
  puts "We hear you're looking for an ice cream shop."
  puts "\n\nPlease input your current addres:"
  address = gets.chomp
end

def find_current_location_url #Geocoding
  Addressable::URI.new(
    :scheme => "https",
    :host => "maps.googleapis.com",
    :path => "maps/api/geocode/json",
    :query_values => {
      address: input_address,
      sensor: false
    }
  ).to_s
end

def directions(start_point, end_point)
  Addressable::URI.new(
    :scheme => "https",
    :host => "maps.googleapis.com",
    :path => "maps/api/directions/json",
    :query_values => {
      origin: start_point,
      destination: end_point,
      sensor: false,
      mode: "walking"
    }
  ).to_s
end

def search_parameters
  key = get_api_key
  location = find_current_location
  radius = #dont use this, use rankby=distance
  sensor = false
  keyword = "Ice Cream" #or use types to specify
end

def create_url(current_coordinate)
  Addressable::URI.new(
    :scheme => "https",
    :host => "maps.googleapis.com",
    :path => "maps/api/place/nearbysearch/json",
    :query_values => {
      key: get_api_key,
      location: current_coordinate,
      sensor: false,
      keyword: "Ice Cream", #or use types to specify
      rankby: "distance"
    }
  ).to_s
end

def current_location_coordinates
  raw_json = RestClient.get(find_current_location_url)
  parsed_json = JSON.parse(raw_json)
  coordinates = parsed_json["results"][0]["geometry"]["location"]
  "#{coordinates.values.first}, #{coordinates.values.last}"
end

current_coordinate = current_location_coordinates

def end_point_coordinates(current_coordinate)
  raw_json = RestClient.get(create_url(current_coordinate))
  parsed_json = JSON.parse(raw_json)
  coordinates = parsed_json["results"][0]["geometry"]["location"]
    "#{coordinates.values.first}, #{coordinates.values.last}"
end

def get_directions_json(current_coordinate)
  raw_json = RestClient.get(directions(current_coordinate, end_point_coordinates(current_coordinate)))
  parsed_json = JSON.parse(raw_json)
end

def convert_directions_json_to_string(json_obj)
  return_str = ""
  json_obj["routes"][0]["legs"][0]["steps"].each do |x|
    return_str << x["html_instructions"] << ". "
  end
  return_str.gsub("<b>","").gsub("</b>","").gsub("</div>","").gsub('<div style="font-size:0.9em">',"")
end




puts convert_directions_json_to_string(get_directions_json(current_coordinate))

