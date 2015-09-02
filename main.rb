puts "hello"

require 'echonest-ruby-api'
require 'awesome_print'
apikey = 'TH5TZNHSMONJIJA0M'

artist = Echonest::Artist.new(apikey, 'Weezer').profile

#ap artist.songs

song = Echonest::Song.new(apikey)

params = { 
	#mood: "sad^.5", 
	artist_id: artist.id,
	results: 10, 
	#min_tempo: 130, 
	#max_tempo: 150 
}

songSearch = song.search(params)

ap songSearch