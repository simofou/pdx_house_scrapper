#
# This "store" tool stores a user-entered address with relevant data to the
# local SQL database
#

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

def backfill_table()
  # backfill new table from the old addresses
  get_addys_query = "SELECT address FROM nopo;"
  addys_arr = execute_query(get_addys_query)
  address_not_added = []

  addys_arr.each do |addy|
    address = addy['address'].to_s.strip
    puts "adding #{address}"
    owner = PortlandMaps::PortlandMapsClass.get_homeowner(address)
    neighborhood = PortlandMaps::PortlandMapsClass.get_neighborhood(address)

    add_addy_query = "
      INSERT INTO test
      (address, homeowner, neighborhood)
      VALUES
      ('#{address}', '#{owner}', '#{neighborhood}')
    "
    begin 
      execute_query(add_addy_query)
    rescue 
      print "#{address} ======> not added!!!! do this one manually..."
      address_not_added << address
    end
  end
  puts "done!" 
  puts "address that you need to add manually: #{address_not_added}"
end

# user prompt

backfill_table()

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
 
## useful queries:

add_addy_query = "
INSERT INTO test
  (address, owner, neighborhood, notes, priority)
VALUES
  ('#{address}', '#{owner}', '#{neighborhood}', '#{notes}!', #{priority})
"

select_addy_from_table = "SELECT address FROM nopo_homes;"

select_owner_from_addy = "SELECT owner FROM nopo_homes WHERE address='<address>'"

update_owner_from_addy = "
  UPDATE nopo_homes
  SET owner = <owner>'
  WHERE address = '<address>';
"
update_addy_from_addy = "
  UPDATE nopo_homes
  SET address = <new_address>'
  WHERE address = '<address_in_table>';
"

update_neighborhood_from_addy = "
  UPDATE nopo_homes
  SET neighborhood = <neighborhood>'
  WHERE address = '<address>';
"

