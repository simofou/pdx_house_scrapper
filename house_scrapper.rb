class HouseScrapper
  require_relative "zillow.rb"
  require_relative "portland_maps.rb"
  
  EXAMPLE_ADDRESS = "5080 NE 56th Ave"

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

    next if PortlandMaps::PortlandMapsClass.get_homeowner(address) == nil
      PortlandMaps::PortlandMapsClass.get_lot_size(address)
      PortlandMaps::PortlandMapsClass.get_lot_zoning(address)
      PortlandMaps::PortlandMapsClass.get_home_size(address)
      PortlandMaps::PortlandMapsClass.get_year_built(address)
      PortlandMaps::PortlandMapsClass.get_market_value(address)
      location_coordinates = 
        PortlandMaps::PortlandMapsClass.get_location_coordinates(address)
      Zillow::ZillowClass.get_zestimate(location_coordinates, address)
  end
end
