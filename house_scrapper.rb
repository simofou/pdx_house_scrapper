require 'active_record'
require 'faraday'
require 'pry'
require 'json'
require 'mysql2'
require 'active_support/core_ext/numeric/conversions'
require 'dotenv/load'

API_KEY = ENV['API_KEY']
EXAMPLE_ADDRESS = "5080 NE 56th Ave"

puts "api key: #{API_KEY}"

print "enter an address or hit the enter key to run with example address (5080 NE 56th Ave): "
address = gets.chomp
puts "------------------------------------------------------------------"

######
###### sql query to db to store table values to hash
######

def execute_query(query)
  client = Mysql2::Client.new(:host => "localhost", :username => "root")
  binding.pry
  results = client.query("#{query}")

  if results.present?
    return results
  else
    return nil 
  end
end

query = "SELECT address FROM nopo;"
# execute_query(query)

#######
####### fetch owner data from maps api
#######

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

  return response_body = JSON.parse(response.body)["results"][0]
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
  else
    raise "invalid address, please enter a valid addy foo"
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

if address == ""
  address = EXAMPLE_ADDRESS
end

get_homeowner("#{address}")
get_lot_size("#{address}")
get_lot_zoning("#{address}")
get_home_size("#{address}")
get_market_value("#{address}")

#######
####### push data back to db
#######

query = "FROM * UPDATE bla bloo"
# execute_query()
