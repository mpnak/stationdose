require 'echowrap'

Echowrap.configure do |config|
  config.api_key =       'TH5TZNHSMONJIJA0M'
  config.consumer_key =  '32493a09dd60437da7e113079018b6e3'
  config.shared_secret = '4YlKc6wWRCWt8cyFI7chCQ'
end


puts Echowrap.taste_profile_list.inspect