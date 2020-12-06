
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

require 'mysql2'
