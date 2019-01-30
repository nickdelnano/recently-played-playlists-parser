open Utils;;
open PlaylistTypes;;

let make_playlist (username : string) (playlist_name  : string) (description : string) (tokens : playlist_token list) : string = 
  let (ast, leftover_toks) = Parser.parse_playlist_expr tokens in

  print_string ("\nRemaining tokens: " ^ (string_of_list ~newline:true string_of_playlist_token leftover_toks));

  let track_ids = Eval.make_playlist ast username in

  let track_ids_csv = String.concat "," track_ids in

  let resp = Http.call_make_playlist_endpoint username playlist_name track_ids_csv description in

  print_string "Response:";
  print_string resp;
  
  resp
;;

(*
(100 most played from Jan 1 2016 - Jan 1 2017) AND (Tracks played < 2 times between Jan 1 2017 - Jan 1 2018)
*)
(* let toks = [Tok_Playlist; Tok_Time_Begin("1451649600"); Tok_Time_End("1483272000"); Tok_Comparator(2); Tok_Count(1); Tok_Limit(100); Tok_Filter_End; Tok_And; Tok_Playlist; Tok_Time_Begin("1483272000"); Tok_Time_End("1514808000"); Tok_Comparator(0); Tok_Count(2); Tok_Filter_End; Tok_End];; *)

(* Top 100 most played *)
let toks = [Tok_Playlist; Tok_Comparator(2); Tok_Count(1); Tok_Limit(100); Tok_Filter_End; Tok_End];;

(* Make `username` match the `username` column in the MySQL `users` table. *)
let username = "test_user" in
let playlist_name = "bla" in
let description = "my first generated playlist!" in

make_playlist username playlist_name description toks
