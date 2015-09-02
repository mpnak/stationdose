require 'json'
require 'bundler'
Bundler.require



#beginning = Time.now
Echowrap.configure do |config|
  config.api_key =       'TH5TZNHSMONJIJA0M'
  config.consumer_key =  '32493a09dd60437da7e113079018b6e3'
  config.shared_secret = '4YlKc6wWRCWt8cyFI7chCQ'
end

#tasteProfileHipHop = 'CAOOZHL14F61BBA869'

#puts Echowrap.taste_profile_keyvalues(:id => tasteProfileHipHop).inspect

#puts Echowrap.taste_profile_list.inspect

#puts Echowrap.taste_profile_read(:id => tasteProfileHipHop).inspect

#puts Echowrap.playlist_static(:type => "catalog", :results => 12, :seed_catalog => "CAOOZHL14F61BBA869", :item_keyvalues => {:undergroundness => "3"}).inspect


file = File.read('tasteprofiletest.json')
object = JSON.parse(file)

# Note the following are some examples. Comment then out or delete as you understand them.
# Note `ap`  is just like `puts` but formats the output

# object is a ruby Array - which is a collection of objects
# we can count the items in this array using the `count` method
#
puts object.count

# We can access each item using an index. Note that the index starts at 0
# To get the first item in the array we use
ap object[0]

# To get 10th item we can say
ap object[9]

# And the last one
puts object[object.count - 1]

# Or we can cheat a little
ap object.last

# Each object in the array is a ruby Hash
puts object[0].class == Hash

# A Hash consists of a list of key and value pairs. The key is typically a Sting like "action" or "item"   while the value can be anything.

# Lets look at the first item, it looks like this:
# {
#   "action"=>"update",
#    "item"=>{
#       "song_id"=>"SOFSRZH1315CD477A3",
#        "item_keyvalues"=>{
#           "undergroundness"=>"1"
#         }
#     }
# }
#
# 
# This Hash has two keys:  "action" and "item", the value for "action" is "update" while the value or "item" is another Hash.
#
# We can access the values of a hash using [] brackets and the keys
ap object.first["action"] # => "update"
ap object.first["item"] # => {"song_id"=>"SOFSRZH1315CD477A3", "item_keyvalues"=>{"undergroundness"=>"1"}}

# As you can see the 'item' hash has two keys "song_id" and "item_keyvalues",  the value for "item_keyvalues" is another hash.
ap object.first["item"]["song_id"]
ap object.first["item"]["item_keyvalues"]

# So lets grab the undergroundness
ap object.first["item"]["item_keyvalues"]["undergroundness"]



# You can loop or iterate through an Array using the `each` method.
# So if we wanted to print a list of each songs id and undergroundness we can do it like this
object.each do |song|
  if song["item"]["item_keyvalues"] # some songs don't have "item_keyvalues so we need an if statment to check whether it exists"

    puts "id: #{song['song_id']}, undergroundness: #{song['item']['item_keyvalues']['undergroundness']}"
  end
end


# There is a whole bunch of useful methods for an Array
# We can for example filter or `select` songs that have an undergroundness greater than 1 and return a new array of these songs...
underground_songs =  object.select do |song|
  if song["item"]["item_keyvalues"]
    song["item"]["item_keyvalues"]["undergroundness"].to_i > 1
  end
end

ap underground_songs
