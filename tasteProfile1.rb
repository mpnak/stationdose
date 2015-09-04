require 'json'
require 'bundler'
# require 'echowrap'

require_relative 'config/initializers/echowrap'
Bundler.require

#beginning = Time.now

file = File.read('tasteprofiletest.json')
object = JSON.parse(file)


underground_songs_1 =  object.select do |song|
  if song["item"]["item_keyvalues"]
    song["item"]["item_keyvalues"]["undergroundness"].to_i >= 1 && song["item"]["item_keyvalues"]["undergroundness"].to_i <= 2
  end
end
 
 File.open("public/hipHip1.json","w") do |f|
  f.write(underground_songs_1.to_json)
end

fileHipHop1 = File.read ('public/hipHip1.json')

#testing

# hipHopTasteProfile_1 = Echowrap.taste_profile_create(:name => "hipHip1", :type => 'song')

# ap hipHopTasteProfile_1

# hipHopProfileId_1 = 'CADAFWK14F9559034D'

Echowrap.taste_profile_update(:id => 'CADAFWK14F9559034D', :data => fileHipHop1)

ap Echowrap.taste_profile_read(:id => 'CADAFWK14F9559034D', :results => 10)

# puts Echowrap.taste_profile_read(:id => 'hipHopProfileId').inspect

