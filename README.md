In 2017 and 2018, Spotify [curated a playlist for each user with their most played tracks of the year](https://community.spotify.com/t5/Community-Blog/Your-2018-Wrapped/ba-p/4625551). In 2017 when I got the my first "most played" playlist, I thought it was super cool! I also saw many of my friends were eager to share this data on social media. 

But how could you make your own "most played of the year" playlist. And why does it have to be "most" played -- what if I wanted a "least" played playlist, or to compose playlists based on any metadata or aggregation of metadata for a song/album/artist?

This project stores a users listening history over time and relevanat metadata for the song/album/artist. There is a context-free grammar to permit the definition of a playlist as a query over listening history data. The nature of the grammar allows complex playlists to be defined, such as a playlist that is the result of set operations on multiple playlists. The parser understands a language which represents a playlist and the evaluator walks the AST by querying MySQL, performing logic in python, and outputting a spotify playlist.

I call this "recently-played-playlists" because every playlist will only contain songs that you have previously listened to. This project is meant to allow unrestricted access to identifying your personal listening patterns, and creating playlists that you are unable to do by yourself.

I'm also looking to continue developing if I find interesting ideas. I have a [few examples below that should give you an idea of what's possible](https://github.com/ndelnano/recently-played-playlists-parser/blob/master/README.md#show-me-a-damn-example). Send in any of your own ideas via an issue.

Grammar:
(Terminals are surrounded by backticks)
```
MyCoolPlaylist ::= OrPlaylist

OrPlaylist ::= AndPlaylist `Tok_Or` OrPlaylist | AndPlaylist

AndPlaylist ::= DiffPlaylist `Tok_And` AndPlaylist | DiffPlaylist

DiffPlaylist ::= Playlist `Tok_Diff` DiffPlaylist | Playlist

Playlist ::= `Tok_Playlist` Filter `Tok_Filter_End` | `Tok_RParen` MyCoolPlaylist `Tok_LParen`

Filter ::= `Tok_Time_Begin` | `Tok_Time_End` | `Tok_Agby` | `Tok_Release_Start` | `Tok_Release_End` | `Tok_Count` | `Tok_Limit` | `Tok_Comparator` | `Tok_Saved`
```

## Installing and running
See [recently-played-playlists-puppet](https://github.com/ndelnano/recently-played-playlists-puppet).

## Lexer
There isn't one! To make a playlist, you need to write a list of tokens and feed it to the parser. I think a lexer would be useful if I ever create a UI for designing playlists. More detail near the bottom of the page.

## Parser
Recursive descent, right recursive, lookahead(1)

## Data types and evaluation
The basis of a playlist is a `playlist_expr` type, which contains exactly one `filter` object. A `playlist_expr` can be combined via AND, OR, or DIFF with another playlist. Since `playlist_expr` is a recursive data type, this allows a single `playlist_expr` to be composed of infinitely many `playlist_expr`'s. 
```
type playlist_expr =
  | Playlist of filter
  | Playlist_Or of playlist_expr * playlist_expr
  | Playlist_And of playlist_expr * playlist_expr
    (* playlist a - playlist b *)
  | Playlist_Diff of playlist_expr * playlist_expr

type filter =
  Filter of filter_cl

class filter_cl =
  object (self)
    (* Earliest UTC *)
    val mutable time_begin = ( "0" : string )

    (* Latest UTC -- 11 digits *)
    val mutable time_end = ( "99999999999" : string )

    (* Only track_id for now *)
    val mutable agby = ( "track_id" : string )

    (* If set, must be > 0 *)
    val mutable limit = ( -1 : int )

    (* If set, must be [0.1]. 0: false, 1: true *)
    val mutable saved = ( -1 : int )

    (* If set, must be > 0 *)
    val mutable count = ( -1 : int )

    (* If set, must be [0,3]. 0: <, 1: <=, 2: >, 3: >=*)
    (* If value is [0,1], ORDER BY ASC, if [2,3], ORDER BY DESC *)
    (* This is necessary for combining with a LIMIT clause *)
    val mutable comparator = ( -1 : int )

    (* Earliest UTC *)
    val mutable release_start = ( "0" : string )

    (* Latest UTC -- 11 digits *)
    val mutable release_end = ( "99999999999" : string )

    (* release_start and release_end are not supported in the HTTP API *)

```

The `filter_cl` class and its attributes map directly to 1 SQL query. When a `playlist_expr` is evaluated and the `Playlist` type is reached (at the deepest level of parsing the AST), an HTTP request is sent to [recently-played-playlists](https://github.com/ndelnano/recently-played-playlists), and a SQL query is constructed and evaluated, returning the matching results. See [here](https://github.com/ndelnano/recently-played-playlists#where-is-the-magic) for how the SQL query is constructed.

The code then merges the results of each `Playlist` evaluation as it walks back up the AST. When the entire AST is evaluated, it makes a second call to recently-played-playlists to create the playlist.

Here is the evaluation of the AST that the parser emits:
```
let rec eval_playlist_expr e username =
    match e with
    | Playlist_Or(x,y) ->
        let s1 = eval_playlist_expr x username in
        let s2 = eval_playlist_expr y username in
        SS.union s1 s2
    | Playlist_And(x,y) ->
        let s1 = eval_playlist_expr x username in
        let s2 = eval_playlist_expr y username in
        SS.inter s1 s2
    | Playlist_Diff(x,y) ->
        let s1 = eval_playlist_expr x username in
        let s2 = eval_playlist_expr y username in
        SS.diff s1 s2
    | Playlist(filter) ->
        (match filter with
        Filter(f) ->
            let resp = Http.call_process_filter_endpoint f username in
            let song_ids = Str.split (Str.regexp ",") resp in
            List.fold_right SS.add song_ids SS.empty)
```
(Head) recursion makes it stupid easy!

## Grammar

Token data types:
```
type playlist_token = 
  | Tok_Or
  | Tok_And
  | Tok_Diff
  | Tok_Playlist
  | Tok_Filter_End
  | Tok_Time_Begin of string
  | Tok_Time_End of string
  | Tok_Agby of string
  | Tok_Release_Start of string
  | Tok_Release_End of string
  | Tok_Count of int (* If set, must be > 0. *)
  | Tok_Comparator of int (* If set, must be [0,3]. 0 : <, 1 : <=, 2 : >, 3 : >=. Works in combination with `Tok_Count`.*)
  | Tok_Saved of int (* If set, must be [0,1]. 0 is not saved, 1 is saved. *)
  | Tok_Limit of int (* If set, must be > 0. *)
  | Tok_End (* This token exists to satisfy the lookahead(1) parser and signal the end of a token stream. *)


  (* Forcing assocativity not supported, yet. Should be eazy. I have included these in the grammar, though.
  | Tok_RParen
  | Tok_LParen
  *)
```

## Creating a playlist
`make` will compile and run the tests and compile `main.ml`. `main.ml` is the interface to the parser. Follow the structure of the file and add your own list of tokens. `./main.byte` will run `main.ml` and create a playlist for your Spotify account (assuming you've followed recently-played-playlists-puppet and have the HTTP API running!).

I only have very "top-level" tests for the parser. I sleep well at night due to ocaml's type system and "believing in the recursion".

## Show me a damn example
You can use any of the fields documented above in the `filter_cl` class.

Here's a simple playlist: Top 100 most played of all time

```
let toks = [Tok_Playlist; Tok_Comparator(2); Tok_Count(1); Tok_Limit(100); Tok_Filter_End; Tok_End];;

let username = "test_user" in
let playlist_name = "bla" in
let description = "my first generated playlist!" in

make_playlist username playlist_name description toks
```

The playlist would be turned into this SQL query:
```
SELECT spotify_id FROM
    (
        SELECT
            COUNT(*) as num_plays,
            track_id as id
        FROM songs_played
            WHERE
                user_id={user_id}
                AND played_at > 0
                AND played_at < 99999999999
            GROUP BY track_id
    ) t1
    INNER JOIN tracks using (id)
WHERE num_plays > 1 ORDER BY num_plays DESC LIMIT 100
```

Another example: 50 most played songs between Jan 1 2017 - Jan 1 2018, that are not saved in your library -- maybe you wish these were in your library, but you have forgotten to add them!
```
let toks = [Tok_Playlist; Tok_Time_Begin("1483272000"); Tok_Time_End("1514808000"); Tok_Saved(0); Tok_Comparator(2); Tok_Count(1); Tok_Limit(50); Tok_Filter_End; Tok_End];;
```

Corresponding SQL query:
```
SELECT spotify_id FROM
    (
        SELECT
            COUNT(*) as num_plays,
            track_id as id
        FROM songs_played
            WHERE
                user_id={user_id}
                AND played_at > 1483272000
                AND played_at < 1514808000
            GROUP BY track_id
    ) t1
    INNER JOIN tracks using (id)
WHERE num_plays > 1 ORDER BY num_plays DESC LIMIT 50
```
But! Since membership in your library is dynamic, a call to the Spotify API checks if any of these songs are in your library, and filters out any that are.

Last one -- let's compose multiple playlists: (100 most played from Jan 1 2016 - Jan 1 2017) AND (Tracks played < 2 times between Jan 1 2017 - Jan 1 2018) -- Your favorite tracks from 2016, that went out of style very quickly!

```
let toks = [Tok_Playlist; Tok_Time_Begin("1451649600"); Tok_Time_End("1483272000"); Tok_Comparator(2); Tok_Count(1); Tok_Limit(100); Tok_Filter_End; Tok_And; Tok_Playlist; Tok_Time_Begin("1483272000"); Tok_Time_End("1514808000"); Tok_Comparator(0); Tok_Count(2); Tok_Filter_End; Tok_End];;
```

Corresponding SQL queries:
```
SELECT spotify_id FROM
    (
        SELECT
            COUNT(*) as num_plays,
            track_id as id
        FROM songs_played
            WHERE
                user_id={user_id}
                AND played_at > 1451649600
                AND played_at < 1483272000
            GROUP BY track_id
    ) t1
    INNER JOIN tracks using (id)
WHERE num_plays > 1 ORDER BY num_plays DESC LIMIT 100

SELECT spotify_id FROM
    (
        SELECT
            COUNT(*) as num_plays,
            track_id as id
        FROM songs_played
            WHERE
                user_id={user_id}
                AND played_at > 1483272000
                AND played_at < 1514808000
            GROUP BY track_id
    ) t1
    INNER JOIN tracks using (id)
WHERE num_plays < 2 ORDER BY num_plays ASC
```
These results will be merged with the logical AND in ocaml.

Hopefully you now have a good idea how this works.

## This is neat, why do I have to construct a token list directly instead of using a fancy UI?
I'd love a nice UI for playlist construction. There's two reasons:
- I think a UI that would only allow construction of valid playlists would be very tedious to make. I think the user would still have to understand what playlist structures are and are not supported, and would have to understand the grammar anyway.
- [recently-played-playlists "Why don't you run this as a service"](https://github.com/ndelnano/recently-played-playlists#why-dont-you-run-this-as-a-service)

## What other kind of parsing could be done??
Literally anything! I'm always thinking about new playlist ideas; please share your thoughts! Here's what I've come up with:
## Albums
- Playlist containing most played all albums
- Playlist containing all albums for which all tracks have been played, X times
## Spotify's ['Audio Features'](https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-features/)
- High energy songs, songs with high 'danceability', similar tempo
- Make a DJ set by sequencing tracks based on their audio features.
I'd have to do some investigation to determine how accurate these attributes are.
## Artists
- Playlist with songs from top listened artists
## Play density
- Playlist of songs that have been played 2x in any week from time period X to time period Y.
  - Could be done easily if you deem a week to be Sunday-Saturday, but searching for every "1 week period" would be complicated and computationally intensive.
## Genre
- This would be awesome! However, I've seen in practice that Spotify's genre tagging is very poor for electronic music, which is what I care the most about. Maybe it would work better for popular music.
## Time of day / Day of week
- Allow any existing filtering, but restrict the tracks that are selected by time of day or day of week. Perhaps you want to filter only for tracks that were played in the morning, or for tracks that were played on the weekend.

Some are easier to implement than others. I picked the initial set of features to maximize utility and ease of implementation. Beyond the utility of having unique playlists, I thought this was an interesting proof of concept to investigate.

## Non-playlist related possible functionalities
- Compare listening histories with friends -- do I listen to more Bon Jovi than Mike?
- Graph visualizations of listening histories

## TODOs
I track all the recently-played-playlists[-parser|-puppet] projects on one [trello board](https://trello.com/b/J5GirlnV/playlist-maker).
