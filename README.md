# This is in mega work in progress state!!!

## Installing and running
You'll need opam and ocamlbuild. Install the dependencies in deps via:

for i in `cat deps`; opam install $i; done

`make` will make the driver (interface.native) and parser tests 

Running `./interface.native` requires that the playlist-maker web server is running on localhost:5000. TODO more details

## Parser
Recursive descent, right recursive, lookahead(1)

## Grammar

note -- symbols that are code formatted are actually their corresponding token value, but denoted as a symbol here for clarity

MyCoolPlaylist ::= OrPlaylist

OrPlaylist ::= AndPlaylist `||` OrPlaylist | AndPlaylist

AndPlaylist ::= DiffPlaylist `&&` AndPlaylist | DiffPlaylist

DiffPlaylist ::= Playlist `&!` DiffPlaylist | Playlist

Playlist ::= `Tok_Playlist` Filter `Tok_Filter_End` | `(` MyCoolPlaylist `)`

Filter ::= `Tok_Time_Begin` | `Tok_Time_End` | `Tok_Agby` | `Tok_Release_Start` | `Tok_Release_End` | `Tok_Count` | `Tok_Limit` | `Tok_Comparator` | `Tok_Saved`


Could definitely ditch Tok_Filter_End, but expecting this token makes the code a bit cleaner

# What other kind of parsing could be done??
Literally anything! I'm always thinking about new playlist ideas too, please share any interesting ones! Here's what I've come up with:
## Album-wise
- Playlist containing most played all albums
- Playlist containing all albums for which all tracks have been played, X times
## Spotify's ['Audio Features'](https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-features/)
- High energy songs, songs with high 'danceability', similar tempo
## Artists
- Playlist with songs from top listened artists
## Play density
- Playlist of songs that have been played 2x in any week from time period X to time period Y.
  - This is probably too complicated and compute intensive to do, at least with the current implementation of using MySQL in recently-played-playlists
## Genre
- This would be awesome! However, I've seen in practice that Spotify's genre tagging is very poor for electronic music, which is what I care the most about. Maybe it would work better for popular music.


# Other possible functionalities
- Compare listening histories with friends -- do I listen to more Bon Jovi than Mike?
- Graphical visualizations of listening histories
