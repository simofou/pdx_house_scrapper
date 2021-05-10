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

    # Helper methods

    def self.owner_is_human?(owner)
      owner.include? ','
    end

    def self.owner_is_single_human?(owner)
      owner_is_human?(owner) && (!owner.include? '&')
    end

    def self.owner_is_multiple_humans?(owner)
      owner_is_human?(owner) && (owner.include? '&')
    end

    def self.format_single_owner(owner)
      owner = owner.strip.split(',')
      owner = owner.insert(0, owner.delete_at(1))
      owner = "#{owner[0].capitalize} #{owner[1].capitalize}"
    end

    def self.format_multiple_owners(owner)
      owner = owner.split('&')
      complete_owner = ""

      owner.each_with_index do |owner, i|
        if owner_is_human?(owner)  
          owner = format_single_owner(owner)
        end

        if i == 0
          complete_owner += owner
        else
          complete_owner += ' & ' + owner
        end
      end
      complete_owner
    end

    def self.format_owner(owner)
      if owner_is_single_human?(owner)
        format_single_owner(owner)  
      elsif owner_is_multiple_humans?(owner)
        format_multiple_owners(owner)
      else
        owner # owner is probably a business so who cares about formatting
      end
    end

    # Portland Maps API methods

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
        response_body["results"][0]
      else
        raise "status #{response.status}: no response body, must be a bad request. check your .env, api key, and params foo"
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
        format_owner(owner)
      else
        puts "invalid address. please enter a valid addy foo"
        puts "try again foo"
        response_body # nil
      end
    end

    def self.get_full_address(address)
      owner = get_homeowner(address)
      response_body = get_request_body_from_address(address)

      address_street = response_body["address"]
      address_city = response_body["city"]
      address_state = response_body["state"]
      address_zip_code = response_body["zip_code_string"]

      "
        #{owner}
        #{address_street}
        #{address_city} #{address_state} #{address_zip_code}
      "
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
      
      body["total_land_area"]
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
      
      body["base_overlay_combination"][0]["code"]
    end

    def self.get_market_value(address)
      response_body = get_request_body_from_address(address)
      market_value = response_body["market_value"]
      
      market_value = market_value&.to_s(:delimited)
    end

    def self.get_real_market_value(address)
      endpoint = "detail/"

      response_body = get_request_body_from_address(address)
      detail_id = response_body["property_id"]

      response = connection.get("#{endpoint}") do |request|
        request.params["detail_type"] = "assessor"
        request.params["detail_id"] = "#{detail_id}"
        request.params["sections"] = "*"
      end

      body = JSON.parse(response.body)["assessment history"].first
      assesement_year = body["year"]
      real_market_value = body["real_market"]

      "#{real_market_value} (#{assesement_year})"
    end

    def self.get_property_taxes(address)
      endpoint = "detail/"

      response_body = get_request_body_from_address(address)
      detail_id = response_body["property_id"]

      response = connection.get("#{endpoint}") do |request|
        request.params["detail_type"] = "assessor"
        request.params["detail_id"] = "#{detail_id}"
        request.params["sections"] = "*"
      end

      body = JSON.parse(response.body)["tax history"].first
      tax_year = body["year"]
      property_tax = body["property_tax"]

      "#{property_tax} (#{tax_year})"
    end

    def self.get_home_size(address)
      response_body = get_request_body_from_address(address)
      home_size_sqft = response_body["square_feet"]
      
      home_size_sqft&.to_s(:delimited)
    end

    def self.get_year_built(address)
      response_body = get_request_body_from_address(address)
      
      response_body["year_built"]
    end

    def self.get_location_coordinates(address)
      response_body = get_request_body_from_address(address)
      longitude = response_body["longitude"]
      latitude = response_body["latitude"]
      
      "#{longitude},#{latitude}"
    end

    def self.get_neighborhood(address)
      response_body = get_request_body_from_address(address)
      neighborhood = response_body["neighborhood"]

      if neighborhood == "CULLY ASSOCIATION OF NEIGHBORS"
        neighborhood = "Cully"
      end

      neighborhood.capitalize
    end
  end
end
