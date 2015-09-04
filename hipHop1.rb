require 'json'
require 'bundler'
Bundler.require

# You have the 'config' stored in a seperate file but it is not loaded automatically. We have to explicity load that file here:
require_relative 'config/initializers/echowrap'


# Lets see what taste profiles exists?
#ap Echowrap.taste_profile_list

# Nice, the hipHopProfile1 already exists.

# It looks like you had the wrong id for the hipHopProfile1 ...
# You had:
#   hipHopProfileId = 'AVPFPD14F9486F72B'
# But compare this to what you see when you run:
#   ap Echowrap.taste_profile_list
# So lets set the correct ID
hipHopProfileId = 'CAVPFPD14F9486F72B'

# Note, a couple of changes of the next line
# for reference, your attempt was this:
#       Echowrap.taste_profile_update(:id => 'hipHopProfileId', :data=> 'fileHipHop1')

# First we read the contents of the file
file_contents = File.read('public/hipHip1.json')

# A quick look to see if the data has loaded correctly (always good to check these things):
#ap file_contents

# Now we are ready to update
Echowrap.taste_profile_update(:id => hipHopProfileId, :data => file_contents)

# Notice that hipHopProfileId is a variable that contains the value of 'CAVPFPD14F9486F72B' which is encased in quotation '' marks. When we reference hipHopProfileId we don't quote it.

ap Echowrap.taste_profile_read(:id => hipHopProfileId)
