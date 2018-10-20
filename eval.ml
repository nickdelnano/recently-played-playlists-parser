open PlaylistTypes
open Common
open Json

open Yojson


let rec eval_playlist_expr e songs user_id = 
    match e with
    | Playlist_Or(x,y) ->
        let s1 = List.fold_right SS.add (eval_playlist_expr x [] user_id) SS.empty in
        let s2 = List.fold_right SS.add (eval_playlist_expr y [] user_id) SS.empty in
        SS.elements (SS.union s1 s2)
    | Playlist_And(x,y) ->
        let s1 = List.fold_right SS.add (eval_playlist_expr x [] user_id) SS.empty in
        let s2 = List.fold_right SS.add (eval_playlist_expr y [] user_id) SS.empty in
        SS.elements (SS.inter s1 s2)
    | AndNot(x,y) ->
        let s1 = List.fold_right SS.add (eval_playlist_expr x [] user_id) SS.empty in
        let s2 = List.fold_right SS.add (eval_playlist_expr y [] user_id) SS.empty in
        SS.elements (SS.diff s1 s2)
    | MP(filter) ->
        match filter with
        Filter(f) ->
          let filter_json  = filters_to_json f in
          []
