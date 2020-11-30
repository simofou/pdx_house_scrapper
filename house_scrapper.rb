class HouseScrapper
  require_relative "zillow_api.rb"
  require_relative "portland_maps_api.rb"
  
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

    next if PortlandMapsApi::PortlandMapsApiClass.get_homeowner("#{address}") == nil
      PortlandMapsApi::PortlandMapsApiClass.get_lot_size("#{address}")
      PortlandMapsApi::PortlandMapsApiClass.get_lot_zoning("#{address}")
      PortlandMapsApi::PortlandMapsApiClass.get_home_size("#{address}")
      PortlandMapsApi::PortlandMapsApiClass.get_market_value("#{address}")
      location_coordinates = 
        PortlandMapsApi::PortlandMapsApiClass.get_location_coordinates("#{address}")
      ZillowApi::ZillowApiClass.get_zestimate(location_coordinates, address)
  end
end
