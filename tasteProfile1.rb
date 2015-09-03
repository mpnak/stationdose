require 'json'
require 'bundler'

Dir["/config/initializers/*.rb"].each {|file| require file }
#require 'hipHop1.rb'
Bundler.require

#beginning = Time.now

file = File.read('tasteprofiletest.json')
object = JSON.parse(file)


underground_songs_1 =  object.select do |song|
  if song["item"]["item_keyvalues"]
    song["item"]["item_keyvalues"]["undergroundness"].to_i >= 1 && song["item"]["item_keyvalues"]["undergroundness"].to_i <= 2
  end
end

fileHipHop1 = File.open("public/hipHip1.json","w") do |f|
  f.write(underground_songs_1.to_json)
end



#puts Echowrap.taste_profile_create(:name => "hipHopProfile1", :type => 'general')

# Echowrap.taste_profile_update(:id => 'hipHopProfileId', :data=> 'fileHipHop1')

# puts Echowrap.taste_profile_read(:id => 'hipHopProfileId').inspect

