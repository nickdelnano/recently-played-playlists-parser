open Utils;;
open PlaylistTypes;;

(* let toks = [Tok_Playlist; Tok_Time_Begin("1"); Tok_Time_End("99999999999"); Tok_Comparator("2"); Tok_Agby("track_id"); Tok_Limit("5"); Tok_Count("100"); Tok_Filter_End; Tok_Or; Tok_Playlist; Tok_Time_Begin("1"); Tok_Time_End("99999999999"); Tok_Limit("5"); Tok_Agby("track_id"); Tok_Saved; Tok_Comparator("2"); Tok_Count("10"); Tok_Filter_End; Tok_End];; *)

(* top 100 most played, not in library *)
let toks = [Tok_Playlist; Tok_Time_Begin("1"); Tok_Time_End("99999999999"); Tok_Saved("0"); Tok_Comparator("2"); Tok_Agby("track_id"); Tok_Limit("100"); Tok_Count("1"); Tok_Filter_End; Tok_End];;

let username = "nickdelnano@gmail.com" in
let playlist_name = "a fun playlist" in
let description = "my first generated playlist!" in

make_playlist username playlist_name description toks
