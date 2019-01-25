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
