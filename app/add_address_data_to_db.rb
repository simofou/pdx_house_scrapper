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
    address = addy['address'].strip.upcase
    puts "adding #{address}"

    # columns:
    owner = PortlandMaps::PortlandMapsClass.get_homeowner(address)
    neighborhood = PortlandMaps::PortlandMapsClass.get_neighborhood(address)

    select_notes_from_addy = "SELECT notes FROM nopo WHERE address='#{address}'"
    select_priority_from_addy = "SELECT priority FROM nopo WHERE address='#{address}'"
    select_letter_sent_from_addy = "SELECT letter_sent FROM nopo WHERE address='#{address}'"

    notes_sql = execute_query(select_notes_from_addy)
      notes = notes_sql.first["notes"]
    priority_sql = execute_query(select_priority_from_addy)
      priority = priority_sql.first["priority"]
    letter_sent_sql = execute_query(select_letter_sent_from_addy)
      letter_sent = letter_sent_sql.first["letter_sent"]

    add_addy_query = "
      INSERT INTO nopo_home_data
      (address, owner, neighborhood, letter_sent, notes, priority)
      VALUES
      ('#{address}', '#{owner}', '#{neighborhood}', '#{letter_sent}', '#{notes}', '#{priority}')
    "
    begin 
      execute_query(add_addy_query)
    rescue 
      puts "#{address} ======> not added!!!! do this one manually..."
      address_not_added << address
    end
  end
  puts "done!" 
  puts "address that you need to add manually: #{address_not_added}"
end

# user prompt

while true do
  puts "------------------------------------------------------------------"
    print "Enter an address you want to store in the database (type 'q' to quit): "
    address = gets.chomp.strip.upcase
  puts "------------------------------------------------------------------"

  if address == "Q"
    break
  end

  next unless owner = PortlandMaps::PortlandMapsClass.get_homeowner(address)
  neighborhood = PortlandMaps::PortlandMapsClass.get_neighborhood(address)

  puts "add a note: "
  notes = gets.chomp.strip

  puts "what priority? "
  priority = gets.chomp.strip.to_i

  add_addy_query = "
  INSERT INTO nopo_home_data
    (address, owner, neighborhood, notes, priority)
  VALUES
    ('#{address}', '#{owner}', '#{neighborhood}', '#{notes}', '#{priority}')
  "
  execute_query(add_addy_query)
  puts "BOOM added #{address} to the database"
end
