#
# letter creator: create personalized letters from a short address
# - grab short address from sql db and create a personalized letter file
# - create sticky letter label for that owner/address
#

require_relative "portland_maps.rb"

EXAMPLE_ADDRESS = "4433 NE FAILING ST"

# helper methods

def owner_is_human?(owner)
  owner.include? ','
end

def owner_is_single_human?(owner)
  owner_is_human?(owner) && (!owner.include? '&')
end

def owner_is_a_human_couple?(owner)
  owner_is_human?(owner) && (owner.include? '&')
end

def format_human_owner(owner, owner_status) # this is so messy needs refactoring
  if owner_status == "single"
    format_owner = owner.split(',')
    return owner = "#{format_owner[-1].capitalize} #{format_owner[0].capitalize}"
  elsif owner_status == "couple"
    format_owner = owner.split('&')
    complete_owner_names = ""
    format_owner.each do |owner|
      owner = format_human_owner(owner, "single").to_s
      complete_owner_names = complete_owner_names + " " + owner
    end
    return complete_owner_names
  end
end

def generate_custom_letter(owner, neighborhood, address)
  if owner_is_single_human?(owner)
    owner = format_human_owner(owner, "single")
  elsif owner_is_a_human_couple?(owner)
    owner = format_human_owner(owner, "couple")
  else  
    owner = "Homeowner" # owner is most likely a business
  end

  letter_template = File.open("./letter_template.txt")
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
    print "what address do you want to generate a letter for (type 'exit' to exit): "
    address = gets.chomp
  puts "------------------------------------------------------------------"

  if address == ""
    address = EXAMPLE_ADDRESS
  elsif address == "exit" 
    break
  end

  next unless owner = PortlandMaps::PortlandMapsClass.get_homeowner(address)
  full_address = PortlandMaps::PortlandMapsClass.get_full_address(address)
  neighborhood = PortlandMaps::PortlandMapsClass.get_neighborhood(address)

  generate_custom_letter(owner, neighborhood, address)
  generate_custom_address_label(full_address)
end
