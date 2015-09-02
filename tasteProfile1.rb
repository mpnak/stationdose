require 'echowrap'
require 'json'
#require 'rubygems'
#require 'ostruct'
#require 'hashie/mash'
require 'hashie'



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


object.extend Hashie::Extensions::DeepFetch

# a nested array
puts object.deep_fetch :action, 0, :update # => 'Open source enthusiasts'





# data = OpenStruct.new(object)

# print object

