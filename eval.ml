open PlaylistTypes
open Common
open Json
open Http

open Yojson

let rec eval_playlist_expr e songs username =
    match e with
    | Playlist_Or(x,y) ->
        let s1 = List.fold_right SS.add (eval_playlist_expr x [] username) SS.empty in
        let s2 = List.fold_right SS.add (eval_playlist_expr y [] username) SS.empty in
        SS.elements (SS.union s1 s2)
    | Playlist_And(x,y) ->
        let s1 = List.fold_right SS.add (eval_playlist_expr x [] username) SS.empty in
        let s2 = List.fold_right SS.add (eval_playlist_expr y [] username) SS.empty in
        SS.elements (SS.inter s1 s2)
    | Playlist_Diff(x,y) ->
        let s1 = List.fold_right SS.add (eval_playlist_expr x [] username) SS.empty in
        let s2 = List.fold_right SS.add (eval_playlist_expr y [] username) SS.empty in
        SS.elements (SS.diff s1 s2)
    | Playlist(filter) ->
        match filter with
        Filter(f) ->
          let resp = call_process_filter_endpoint f username in
          []

let call_spotify_make_playlist username songs = 
    "implement me!"

let make_playlist playlist_expr username = 
  let song_ids = eval_playlist_expr playlist_expr [] username in
  call_spotify_make_playlist username song_ids
