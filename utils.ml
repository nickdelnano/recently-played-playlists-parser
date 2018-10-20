open PlaylistTypes

let string_of_list ?newline:(newline=false) (f : 'a -> string) (l : 'a list) : string =
    "[" ^ (String.concat ", " @@ List.map f l) ^ "]" ^ (if newline then "\n" else "");;

let string_of_playlist_token (t : playlist_token) : string = match t with
  | Tok_Or -> "Tok_Or"
  | Tok_And -> "Tok_And"
  | Tok_And_Not -> "Tok_And_Not"
  | Tok_MP -> "Tok_MP"
  | Tok_Null -> "Tok_Null"
  | Tok_Begin(x) -> "Tok_Begin(" ^ (string_of_int x) ^ ")"
  | Tok_End(x) -> "Tok_End(" ^ (string_of_int x) ^ ")"
  | Tok_Agby(x) -> "Tok_Agby(" ^ x ^ ")"
  | Tok_Release_Start(x) -> "Tok_Release_Start(" ^ string_of_int x ^ ")"
  | Tok_Release_End(x) -> "Tok_Release_End(" ^ string_of_int x ^ ")"
  | Tok_Count(x) -> "Tok_Count(" ^ string_of_int x ^ ")"
  | Tok_Comparator(x) -> "Tok_Comparator(" ^ string_of_int x ^ ")"
  | Tok_Saved -> "Tok_Saved"
  | Tok_Limit(x) -> "Tok_Limit(" ^ string_of_int x ^ ")"
  | Tok_RParen -> "Tok_RParen"
  | Tok_LParen -> "Tok_LParen"

let rec unparse_pre (x: pre_ag_filter) : string = 
  match x with
  | Filter(p) ->
      "Begin: " ^ string_of_int p#get_begin ^ " End: " ^ string_of_int p#get_end ^ " Agby: " ^ p#get_agby ^ " Limit: " ^ string_of_int p#get_limit

let rec unparse_post (x: post_ag_filter) : string = 
  match x with
  | Filter(p) ->
      "Saved: " ^ string_of_int p#get_saved ^ " Count: " ^ string_of_int p#get_count ^ " Comparator " ^ string_of_int p#get_comparator ^ " Release start: " ^ string_of_int p#get_release_start ^ " Release end: " ^ string_of_int p#get_release_end

let rec string_of_playlist_expr (e : playlist_expr) : string =
  let unparse_two (s : string) (e1 : playlist_expr) (e2 : playlist_expr) =
    s ^ "(" ^ string_of_playlist_expr e1 ^ ", " ^ string_of_playlist_expr e2 ^ ")"
  in
  match e with
  | MP(pre, post) ->
      let x = unparse_pre pre in
      let y = unparse_post post in
      "Playlist of (" ^ x ^ " " ^ y ^ ")"
  | Playlist_Or(x,y) ->
      unparse_two "Or" x y
  | Playlist_And(x,y) ->
      unparse_two "And" x y
  | AndNot(x,y) ->
      unparse_two "AndNot" x y
