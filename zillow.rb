module ZillowAPI
  require 'active_record'
  require 'faraday'
  require 'pry'
  require 'json'

  API_KEY = "0a1ced8dca6ee92de874882163bd08cb"
  url = "https://api.bridgedataoutput.com/api/v2/"
  address = "6652 NE GOING ST"

  url_radius_to_coordinates = 
  "https://api.bridgedataoutput.com/api/v2/zestimates?access_token=0a1ced8dca6ee92de874882163bd08cb&limit=100&fields=zestimate,address&near=-122.59415,45.55643&radius=0.1"

  response = Faraday.get url_radius_to_coordinates

  response_body = JSON.parse(response.body)
  zillow_home_data = response_body["bundle"] # array of hashes - each hash is a home that matches our query and contains :address, :zestimate...

  zillow_home_data.each do |home_data|
    puts home_data["address"]
    next unless home_data["address"].include? "#{address}"
      puts "zestimate for #{address} is: $#{home_data["zestimate"]}"
      break
  end
end

