#
# letter creator: create personalized letters from a short address
# - grab short address from sql db and create a personalized letter file
# - create sticky letter label for that owner/address

require 'mysql2'
require_relative "portland_maps.rb"

# #####
# ##### sql query to db to store table values to hash
# #####

# def execute_query(query)
#   client = Mysql2::Client.new(:host => "localhost", :username => "root")
#   binding.pry
#   results = client.query("#{query}")

#   if results.present?
#     return results
#   else
#     return nil 
#   end
# end

# query = "SELECT address FROM nopo;"
# execute_query(query)

# helper methods

def owner_is_human(owner)
  owner.include? ","
end

def generate_custom_letter(owner, neighborhood, address)
  if owner_is_human(owner)
    format_owner = owner.split(',')
    owner = "#{format_owner[-1].capitalize} #{format_owner[0].capitalize}" # this should live in the homeowner method
  else
    owner = "Homeowner"
  end

  letter_template = File.open("./letter_template.txt")
  letter_template_data = letter_template.read
  custom_letter = letter_template_data
    .sub!("<homeowner>", "#{owner}")
    .sub!("<neighborhood>", "#{neighborhood.capitalize}")
    .sub!("<address_street>", "#{address.capitalize}")
  letter_template.close

  formated_address = address.delete(' ').downcase
  puts "writing custom letter: /tmp/letter_generator/custom_letter_#{formated_address}.txt"
  File.write("/tmp/letter_generator/custom_letter_#{formated_address}.txt", "#{custom_letter}")
end

def generate_custom_address_label(address, full_address)
  formated_address = address.delete(' ').downcase
  puts "writing address label: /tmp/letter_generator/custom_address_label_#{formated_address}.txt"
  File.write("/tmp/letter_generator/custom_address_label_#{formated_address}.txt", "#{full_address}")
end

# user prompt:

while true do
  puts "------------------------------------------------------------------"
    print "what address do you want to generate a letter for (type 'exit' to exit): "
    address = gets.chomp
  puts "------------------------------------------------------------------"

  if address == ""
    address = EXAMPLE_ADDRESS
  elsif address == "exit" 
    break
  end

  owner = PortlandMaps::PortlandMapsClass.get_homeowner(address)
  full_address = PortlandMaps::PortlandMapsClass.get_full_address(address)
  neighborhood = PortlandMaps::PortlandMapsClass.get_neighborhood(address)

  generate_custom_letter(owner, neighborhood, address)
  generate_custom_address_label(address, full_address)
end
