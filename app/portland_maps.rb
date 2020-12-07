# Use the Portland Maps API to grab data for an address

module PortlandMaps
  class PortlandMapsClass 
    require 'active_record'
    require 'faraday'
    require 'pry'
    require 'json'
    require 'active_support/core_ext/numeric/conversions'
    require 'dotenv/load'

    API_KEY = ENV['PDX_MAPS_API_KEY']

    # helper methods

    def self.connection()
      url = "https://www.portlandmaps.com/api/"

      @connection = Faraday.new(
        url: "#{url}",
        params: {api_key: "#{API_KEY}"},
        headers: {"Content-Type" => "application/json"}
      )
    end

    def self.get_request_body_from_address(address)
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

    def self.get_homeowner(address)
      # api call to portland maps to get owner name
      # ex httpie call:
      # http https://www.portlandmaps.com/api/assessor/ 
      # api_key=="api_key_goes_here" address=="4445 ne wygant"
      response_body = get_request_body_from_address(address)
      
      if response_body != nil
        owner = response_body["owner"]
        return owner.capitalize
      else
        puts "invalid address. please enter a valid addy foo"
        puts "try again foo"
        return response_body # nil
      end
    end

    def self.get_full_address(address)
      owner = get_homeowner(address)
      response_body = get_request_body_from_address(address)

      address_street = response_body["address"]
      address_city = response_body["city"]
      address_state = response_body["state"]
      address_zip_code = response_body["zip_code_string"]

      full_address = "
        #{owner}
        #{address_street}
        #{address_city} #{address_state} #{address_zip_code}
      "
      return full_address
    end

    def self.get_lot_size(address)
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

      return lot_size_sqft
    end

    def self.get_lot_zoning(address)
      endpoint = "detail/"

      response_body = get_request_body_from_address(address)
      detail_id = response_body["property_id"]

      response = connection.get("#{endpoint}") do |request|
        request.params["detail_type"] = "zoning"
        request.params["detail_id"] = "#{detail_id}"
      end  

      body = JSON.parse(response.body)["zoning"]
      lot_zoning_code = body["base_overlay_combination"][0]["code"]

      return lot_zoning_code
    end

    def self.get_market_value(address)
      response_body = get_request_body_from_address(address)
      market_value = response_body["market_value"]
      market_value = market_value&.to_s(:delimited)

      return market_value
    end

    def self.get_home_size(address)
      response_body = get_request_body_from_address(address)
      home_size_sqft = response_body["square_feet"]
      home_size_sqft = home_size_sqft&.to_s(:delimited)

      return home_size_sqft
    end

    def self.get_year_built(address)
      response_body = get_request_body_from_address(address)
      year_built = response_body["year_built"]

      return year_built
    end

    def self.get_location_coordinates(address)
      response_body = get_request_body_from_address(address)
      longitude = response_body["longitude"]
      latitude = response_body["latitude"]
      location_coordinates = "#{longitude},#{latitude}"
      
      return location_coordinates
    end

    def self.get_neighborhood(address)
      response_body = get_request_body_from_address(address)
      neighborhood = response_body["neighborhood"]

      if neighborhood == "CULLY ASSOCIATION OF NEIGHBORS"
        neighborhood = "Cully"
      end

      return neighborhood.capitalize
    end
  end
end
