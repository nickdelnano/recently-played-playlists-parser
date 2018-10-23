open PlaylistTypes

let string_of_list ?newline:(newline=false) (f : 'a -> string) (l : 'a list) : string =
    "[" ^ (String.concat ", " @@ List.map f l) ^ "]" ^ (if newline then "\n" else "");;

let string_of_playlist_token (t : playlist_token) : string = match t with
  | Tok_Or -> "Tok_Or"
  | Tok_And -> "Tok_And"
  | Tok_Diff -> "Tok_Diff"
  | Tok_Playlist -> "Tok_Playlist"
  | Tok_Filter_End -> "Tok_Filter_End"
  | Tok_Time_Begin(x) -> "Tok_Time_Begin(" ^ x ^ ")"
  | Tok_Time_End(x) -> "Tok_Time_End(" ^ x ^ ")"
  | Tok_Agby(x) -> "Tok_Agby(" ^ x ^ ")"
  | Tok_Release_Start(x) -> "Tok_Release_Start(" ^ x ^ ")"
  | Tok_Release_End(x) -> "Tok_Release_End(" ^ x ^ ")"
  | Tok_Count(x) -> "Tok_Count(" ^ x ^ ")"
  | Tok_Comparator(x) -> "Tok_Comparator(" ^ x ^ ")"
  | Tok_Saved -> "Tok_Saved"
  | Tok_Not_Saved -> "Tok_Not_Saved"
  | Tok_Limit(x) -> "Tok_Limit(" ^ x ^ ")"
  (* TODO: permit forcing assocativity
  | Tok_RParen -> "Tok_RParen"
  | Tok_LParen -> "Tok_LParen"
  *)
  | Tok_End -> "Tok_End"

(* potential TODO: this output doesn't look very good, but its decent for a quick fix *)
let rec unparse_filter (x: filter) : string = 
  match x with
  | Filter(p) ->
      "Begin: " ^ p#get_time_begin ^ "\nEnd: " ^ p#get_time_end ^ "\nAgby: " ^ p#get_agby ^ "\nLimit: " ^ p#get_limit ^ "\nSaved: " ^ p#get_saved ^ "\nCount: " ^ p#get_count ^ "\nComparator " ^ p#get_comparator ^ "\nRelease start: " ^ p#get_release_start ^ "\nRelease end: " ^ p#get_release_end

let rec string_of_playlist_expr (e : playlist_expr) : string =
  let unparse_two (s : string) (e1 : playlist_expr) (e2 : playlist_expr) =
    s ^ "(" ^ string_of_playlist_expr e1 ^ ", " ^ string_of_playlist_expr e2 ^ ")"
  in
  match e with
  | Playlist(f) ->
      let x = unparse_filter f in
      "Playlist of \n(" ^ x ^ "\n)\n"
  | Playlist_Or(x,y) ->
      unparse_two "Or\n\t" x y
  | Playlist_And(x,y) ->
      unparse_two "And\n\t" x y
  | Playlist_Diff(x,y) ->
      unparse_two "Diff\n\t" x y
