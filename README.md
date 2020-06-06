# SpotifySearchDecoderExample
Decode Spotify Search JSON in Swift using Decodable and CodingKeys  

This demonstrates how to decode JSON from Spotify's search API into an in-memory object.  
From there, the in-memory objects can be used as desired -- eg. displaying artists in a list.

This example uses Spotify JSON retreived from Spotify's Search Console: https://developer.spotify.com/console/get-search-item/. 
The response is of type 'artist' for search term 'nujabes'.  
The endpoint is https://api.spotify.com/v1/search?q=nujabes&type=artist&limit=1
