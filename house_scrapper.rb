require 'active_record'
require 'faraday'
require 'pry'
require 'json'
require 'active_support/core_ext/numeric/conversions'
require 'dotenv/load'

include ZillowAPI

API_KEY = ENV['PDX_MAPS_API_KEY']
EXAMPLE_ADDRESS = "5080 NE 56th Ave"

# helper methods

def connection()
  url = "https://www.portlandmaps.com/api/"

  @connection = Faraday.new(
    url: "#{url}",
    params: {api_key: "#{API_KEY}"},
    headers: {"Content-Type" => "application/json"}
  )
end

def get_request_body_from_address(address)
  endpoint = "assessor/"
  address = address.to_s

  response = connection.get("#{endpoint}") do |request|
    request.params["address"] = "#{address}"
  end
  
  response_body = JSON.parse(response.body)

  if response_body["status"] != "error"
    return response_body["results"][0]
  else
    raise "no response body, must be a bad request. check your .env, api key, and params foo"
  end
end

def get_homeowner(address)
  # api call to portland maps to get owner name
  # ex httpie call:
  # http https://www.portlandmaps.com/api/assessor/ 
  # api_key=="api_key_goes_here" address=="4445 ne wygant"
  response_body = get_request_body_from_address(address)
  
  if response_body != nil
    owner = response_body["owner"]
    puts "owner of #{address}: #{owner}"
    return owner
  else
    puts "invalid address. please enter a valid addy foo"
    puts "try again foo"
    return response_body
  end
end

def get_lot_size(address)
  endpoint = "detail/"

  response_body = get_request_body_from_address(address)
  detail_id = response_body["property_id"]

  response = connection.get("#{endpoint}") do |request|
    request.params["detail_type"] = "assessor"
    request.params["detail_id"] = "#{detail_id}"
  end  

  body = JSON.parse(response.body)["general"]
  lot_size_sqft = body["total_land_area_sqft"]
  lot_size_sqft = lot_size_sqft.to_s(:delimited)

  puts "lot size in sqft: #{lot_size_sqft}"
end

def get_lot_zoning(address)
  endpoint = "detail/"

  response_body = get_request_body_from_address(address)
  detail_id = response_body["property_id"]

  response = connection.get("#{endpoint}") do |request|
    request.params["detail_type"] = "zoning"
    request.params["detail_id"] = "#{detail_id}"
  end  

  body = JSON.parse(response.body)["zoning"]
  lot_zoning_code = body["base_overlay_combination"][0]["code"]

  puts "lot zoning code: #{lot_zoning_code}"
end

def get_market_value(address)
  response_body = get_request_body_from_address(address)
  market_value = response_body["market_value"]
  market_value = market_value.to_s(:delimited)

  puts "current market value: $#{market_value}"
end

def get_home_size(address)
  response_body = get_request_body_from_address(address)
  home_size_sqft = response_body["square_feet"]
  home_size_sqft = home_size_sqft.to_s(:delimited)

  puts "home size in sqft: #{home_size_sqft}"
end

def get_location_coordinates(address)
  response_body = get_request_body_from_address(address)
  longitude = response_body["longitude"]
  latitude = response_body["latitude"]

  location_coordinates = "#{longitude},#{latitude}"
  
  return location_coordinates
end

# run everything

while true do
  puts "------------------------------------------------------------------"
  print "Enter an address or hit the enter key to run with example address (or type 'exit' to exit): "
  address = gets.chomp
  puts "------------------------------------------------------------------"

  if address == ""
    address = EXAMPLE_ADDRESS
  elsif address == "exit" 
    break
  end

  next if get_homeowner("#{address}") == nil
  get_lot_size("#{address}")
  get_lot_zoning("#{address}")
  get_home_size("#{address}")
  get_market_value("#{address}")

  location_coordinates = get_location_coordinates("#{address}")
  ZillowAPI::ZillowAPIClass.get_zestimate(location_coordinates, address)
end
