require 'json'
require 'bundler'
require 'echowrap'
Bundler.require




hipHopProfileId = 'AVPFPD14F9486F72B'

Echowrap.taste_profile_update(:id => 'hipHopProfileId', :data=> 'fileHipHop1').inspect

puts Echowrap.taste_profile_read(:id => 'hipHopProfileId').inspect