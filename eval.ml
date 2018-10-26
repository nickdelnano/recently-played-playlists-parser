open PlaylistTypes
open Common
open Json
open Http

(* 
TODO: Using sets like this won't preserve order on things like most played. To do this, I'd need to use lists and have to worry about tail recursiveness
-- Not sure if forcing this ordering is worth it.
*)

let rec print_list = function 
[] -> ()
| e::l -> print_string e ; print_string " " ; print_list l

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
        match filter with
        Filter(f) ->
          let resp = call_process_filter_endpoint f username in
          print_string "\n";
          print_string resp;
          print_string "\n";
          let song_ids = Str.split (Str.regexp ",") resp in
          List.fold_right SS.add song_ids SS.empty

let set_elements_to_list ele lst =
    ele::lst

let call_spotify_make_playlist username songs = 
    "implement me!"

let make_playlist playlist_expr username = 
  let song_ids_set = eval_playlist_expr playlist_expr username in
  let song_ids = SS.fold set_elements_to_list song_ids_set [] in
  print_string "Here is your playlist!\n";
  print_list song_ids;
  call_spotify_make_playlist username song_ids

