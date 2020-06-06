import Foundation
/**
    This demonstrates how to decode JSON from Spotify's search API into an in-memory object.
    From there, the in-memory objects can be used as desired -- eg. displaying artists in a list.

    This is a sample Spotify JSON response of type 'artist' for search term 'nujabes'.
    The endpoint is https://api.spotify.com/v1/search?q=nujabes&type=artist&limit=1
 
    This sample JSON is retreived from Spotify's Search Console: https://developer.spotify.com/console/get-search-item/
 **/
let spotifyArtistJson = """
{
  "artists": {
    "href": "https://api.spotify.com/v1/search?query=nujabes&type=artist&offset=0&limit=1",
    "items": [
      {
        "external_urls": {
          "spotify": "https://open.spotify.com/artist/3Rq3YOF9YG9YfCWD4D56RZ"
        },
        "followers": {
          "href": null,
          "total": 439243
        },
        "genres": [
          "chillhop",
          "downtempo",
          "japanese chillhop",
          "jazz rap"
        ],
        "href": "https://api.spotify.com/v1/artists/3Rq3YOF9YG9YfCWD4D56RZ",
        "id": "3Rq3YOF9YG9YfCWD4D56RZ",
        "images": [
          {
            "height": 640,
            "url": "https://i.scdn.co/image/893d9987e484b87e034f67407da2d9c4e4657914",
            "width": 640
          },
          {
            "height": 320,
            "url": "https://i.scdn.co/image/6ec49f612576e1614677f83cf45e7a3997d56518",
            "width": 320
          },
          {
            "height": 160,
            "url": "https://i.scdn.co/image/f2bd165812c0469debe07ae5c7d384b947146079",
            "width": 160
          }
        ],
        "name": "Nujabes",
        "popularity": 64,
        "type": "artist",
        "uri": "spotify:artist:3Rq3YOF9YG9YfCWD4D56RZ"
      }
    ],
    "limit": 1,
    "next": "https://api.spotify.com/v1/search?query=nujabes&type=artist&offset=1&limit=1",
    "offset": 0,
    "previous": null,
    "total": 3
  }
}
"""

// create data to be decoded
let spotifyArtistData = spotifyArtistJson.data(using: .utf8)!

// SpotifyArtist model
struct SpotifyArtist: Decodable {
    let href: String
    let spotifyId: String
    let name: String
    let popularity: Int
    let type: String
    let uri: String
    let images: [SpotifyArtist.Image]
    let genres: [String]
    let followers: Int
    
    enum CodingKeys: String, CodingKey {
        case href
        case spotifyId = "id"
        case name
        case popularity
        case type
        case uri
        case images
        case genres
        case followers
    }
    
    // Image model
    struct Image: Decodable {
        let height: Int
        let width: Int
        let url: String
        
        enum CodingKeys: String, CodingKey {
            case height
            case width
            case url
        }
     
        init(from decoder: Decoder) throws {
            let images = try decoder.container(keyedBy: CodingKeys.self)
            height = try images.decode(Int.self, forKey: .height)
            width = try images.decode(Int.self, forKey: .width)
            url = try images.decode(String.self, forKey: .url)
        }
    }
    
    // FollowersMetadata model
    struct FollowersMetadata: Decodable {
        let total: Int
        
        enum CodingKeys: String, CodingKey {
            case total
        }
        
        init(from decoder: Decoder) throws {
            let content = try decoder.container(keyedBy: CodingKeys.self)
            total = try content.decode(Int.self, forKey: .total)
        }
    }
    
    init(from decoder: Decoder) throws {
        let items = try decoder.container(keyedBy: CodingKeys.self)
        href = try items.decode(String.self, forKey: .href)
        spotifyId = try items.decode(String.self, forKey: .spotifyId)
        name = try items.decode(String.self, forKey: .name)
        popularity = try items.decode(Int.self, forKey: .popularity)
        type = try items.decode(String.self, forKey: .type)
        uri = try items.decode(String.self, forKey: .uri)
        images = try items.decode(Array<SpotifyArtist.Image>.self, forKey: .images)
        genres = try items.decode(Array<String>.self, forKey: .genres)
        let followersMetadata = try items.decode(SpotifyArtist.FollowersMetadata.self, forKey: .followers)
        followers = followersMetadata.total
    }
}

// SpotifyResponse model
struct SpotifyResponse: Decodable {
    let href: String
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
    let artists: [SpotifyArtist]
    
    enum CodingKeys: String, CodingKey {
        case artistsContent = "artists"
        case href
        case limit
        case next
        case offset
        case previous
        case total
        case artists = "items"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let artistsContent = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .artistsContent)
        href = try artistsContent.decode(String.self, forKey: .href)
        limit = try artistsContent.decode(Int.self, forKey: .limit)
        next = try? artistsContent.decode(String.self, forKey: .next)
        offset = try artistsContent.decode(Int.self, forKey: .offset)
        previous = try? artistsContent.decode(String.self, forKey: .previous)
        total = try artistsContent.decode(Int.self, forKey: .total)
        artists = try artistsContent.decode(Array<SpotifyArtist>.self, forKey: .artists)
    }
}


// convert JSON into spotify model object
do {
    let nujabesResponse = try JSONDecoder().decode(SpotifyResponse.self, from: spotifyArtistData)
    print(nujabesResponse.artists.first?.genres ?? "")
    // >>> ["chillhop", "downtempo", "japanese chillhop", "jazz rap"]
} catch {
    print("Error: \(error)")
}

