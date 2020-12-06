class HouseScrapper
  require_relative "zillow.rb"
  require_relative "portland_maps.rb"
  
  EXAMPLE_ADDRESS = "5080 NE 56th Ave"

  while true do
    puts "------------------------------------------------------------------"
    print "Enter an address or hit the enter key to run with example address (or type 'exit' to exit): "
    address = gets.chomp.strip
    puts "------------------------------------------------------------------"

    if address == ""
      address = EXAMPLE_ADDRESS
    elsif address == "exit" 
      break
    end

    next unless owner = PortlandMaps::PortlandMapsClass.get_homeowner(address)
      lot_size_sqft = PortlandMaps::PortlandMapsClass.get_lot_size(address)
      lot_zoning_code = PortlandMaps::PortlandMapsClass.get_lot_zoning(address)
      home_size_sqft = PortlandMaps::PortlandMapsClass.get_home_size(address)
      year_built = PortlandMaps::PortlandMapsClass.get_year_built(address)
      market_value = PortlandMaps::PortlandMapsClass.get_market_value(address)
      location_coordinates = 
        PortlandMaps::PortlandMapsClass.get_location_coordinates(address)
      zestimate = Zillow::ZillowClass.get_zestimate(location_coordinates, address)

      puts "
        owner of #{address}: #{owner}
        lot size in sqft: #{lot_size_sqft}
        lot zoning code: #{lot_zoning_code}
        home size in sqft: #{home_size_sqft}
        year built: #{year_built}
        current market value: $#{market_value}
        zestimate: #{zestimate}
      "
  end
end
