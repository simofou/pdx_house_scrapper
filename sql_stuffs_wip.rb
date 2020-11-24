# WIP WIP WIP WIP WIP WIP WIP WIP WIP WIP
# basically here I want to pull and update my local SQL db that has ~100 address to send letters to
#
require 'mysql2'

######
###### sql query to db to store table values to hash
######

def execute_query(query)
  client = Mysql2::Client.new(:host => "localhost", :username => "root")
  binding.pry
  results = client.query("#{query}")

  if results.present?
    return results
  else
    return nil 
  end
end

query = "SELECT address FROM nopo;"
# execute_query(query)


#
# do stuff with house_scrapper.rb to populate all columns in table
#


#######
####### push data back to db
#######

query = "FROM * UPDATE bla bloo"
# execute_query()
