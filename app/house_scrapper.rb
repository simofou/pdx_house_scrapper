  #
# This "scrape" tool scrapes the Portland Maps and Zillow APIs to grab
# data for an address and outputs it to the terminal
#

class HouseScrapper
  require_relative "zillow.rb"
  require_relative "portland_maps.rb"
  require 'active_support/core_ext/numeric/conversions'

  EXAMPLE_ADDRESS = "5080 NE 56th Ave"

  def self.foostimate(zestimate, market_value) # foucher custom estimate ;)
    if (zestimate.blank? || market_value.blank?)
      nil
    else
      zestimate = zestimate.delete(',').to_i
      market_value = market_value.delete(',').to_i

      ((zestimate + market_value * 3) / 4).to_s(:delimited)
    end
  end

  def self.handle_nil_value(command)
    error_message = " not available"
    if command.nil?
      error_message
    else  
      command
    end
  end

  # user prompt

  while true do
    puts "------------------------------------------------------------------"
    print "Enter an address or hit the enter key to run with example address (or type 'q' to quit): "
    address = gets.chomp.strip
    puts "------------------------------------------------------------------"

    if address == ""
      address = EXAMPLE_ADDRESS
    elsif address == "q" 
      break
    end

    next unless owner = PortlandMaps::PortlandMapsClass.get_homeowner(address)
      lot_size_sqft = PortlandMaps::PortlandMapsClass.get_lot_size(address)
      lot_zoning_code = PortlandMaps::PortlandMapsClass.get_lot_zoning(address)
      home_size_sqft = PortlandMaps::PortlandMapsClass.get_home_size(address)
      year_built = PortlandMaps::PortlandMapsClass.get_year_built(address)
      market_value = PortlandMaps::PortlandMapsClass.get_market_value(address)
      real_market_value = PortlandMaps::PortlandMapsClass.get_real_market_value(address)
      property_taxes = PortlandMaps::PortlandMapsClass.get_property_taxes(address)
      location_coordinates = 
        PortlandMaps::PortlandMapsClass.get_location_coordinates(address)
      zestimate =  Zillow::ZillowClass.get_zestimate(location_coordinates, address)
      foostimate = foostimate(zestimate, market_value)

      puts "
        owner of #{address}: #{owner}
        lot size: #{lot_size_sqft}
        lot zoning code: #{lot_zoning_code}
        home size in sqft: #{handle_nil_value(home_size_sqft)}
        year built: #{handle_nil_value(year_built)}
        property taxes: #{property_taxes}
        current market value: $#{market_value}
        \"real\" market value: #{real_market_value}
        zestimate: $#{handle_nil_value(zestimate)}
        foostimate: $#{handle_nil_value(foostimate)}
      "
  end
end
