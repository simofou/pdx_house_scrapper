#
# This "write" tool creates personalized letters from a short address
# - grab short address from sql db and create a personalized letter file
# - create sticky letter label for that owner/address
#

require_relative "portland_maps.rb"

EXAMPLE_ADDRESS = "4433 NE FAILING ST"

def generate_custom_letter(owner, neighborhood, address)
  letter_template = File.open("letter_template.txt")
  letter_template_data = letter_template.read
  custom_letter = letter_template_data
    .sub!("<homeowner>", "#{owner}")
    .sub!("<neighborhood>", "#{neighborhood.capitalize}")
    .sub!("<address_street>", "#{address.capitalize}")
  letter_template.close

  formated_address = address.delete(' ').downcase # formating for file name
  puts "writing custom letter: /tmp/letter_generator/custom_letter_#{formated_address}.txt"
  File.write("/tmp/letter_generator/custom_letter_#{formated_address}.txt", "#{custom_letter}")
end

def generate_custom_address_label(full_address)
  puts "appending address label to: /tmp/letter_generator/custom_address_label.txt"
  File.write("/tmp/letter_generator/custom_address_label.txt", "#{full_address}", mode: 'a')
end

# user prompt:

while true do
  puts "------------------------------------------------------------------"
    print "Enter an address you want to generate a letter for (type 'q' to quit): "
    address = gets.chomp.strip
  puts "------------------------------------------------------------------"

  if address == ""
    address = EXAMPLE_ADDRESS
  elsif address == "q" 
    break
  end

  next unless owner = PortlandMaps::PortlandMapsClass.get_homeowner(address)
  full_address = PortlandMaps::PortlandMapsClass.get_full_address(address)
  neighborhood = PortlandMaps::PortlandMapsClass.get_neighborhood(address)

  generate_custom_letter(owner, neighborhood, address)
  generate_custom_address_label(full_address)
end
