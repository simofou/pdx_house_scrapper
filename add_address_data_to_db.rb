
# #####
# ##### sql query to db to store table values to hash
# #####

require 'mysql2'
require 'active_record'
require 'pry'
require_relative 'portland_maps.rb'

def execute_query(query)
  client = Mysql2::Client.new(
    :host => 'localhost', 
    :username => 'root', 
    :database => 'home_sweet_home'
  )
  results = client.query("#{query}")

  if results.present?
    return results
  else
    return nil 
  end
end

# user prompt:

while true do
  puts "------------------------------------------------------------------"
    print "Enter an address you want to store in the database (type 'q' to quit): "
    address = gets.chomp.strip
  puts "------------------------------------------------------------------"

  if address == "q"
    break
  end

  next unless owner = PortlandMaps::PortlandMapsClass.get_homeowner(address)
  neighborhood = PortlandMaps::PortlandMapsClass.get_neighborhood(address)

  puts "add a note: "
  notes = gets.chomp.strip

  puts "what priority? "
  priority = gets.chomp.strip

  add_addy_query = "
  INSERT INTO test
    (address, homeowner, neighborhood, notes, priority)
  VALUES
    ('#{address}', '#{owner}', '#{neighborhood}', '#{notes}!', #{priority})
  "
  execute_query(add_addy_query)
  puts "BOOM added #{address} to the database"
end
