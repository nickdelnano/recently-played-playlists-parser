open PlaylistTypes
open Utils
exception ParseError of string

(* The functions in this file read bottom to top as I didn't want to use
 * mutual recursion (for no reason other than I forget its limitations/use case.
 * Reading bottom to top will make WAY more sense!
 *)

(* Params: toks: token list, tok: expected next token
 * Consumes tok and returns rest of list *)
let match_playlist_token (toks : playlist_token list) (tok : playlist_token) : playlist_token list =
  match toks with
  | [] -> raise (InvalidInputException(string_of_playlist_token tok))
  | h::t when h = tok -> t
  | h::_ -> raise (InvalidInputException(
      Printf.sprintf "Expected %s from input %s, got %s"
        (string_of_playlist_token tok)
        (string_of_list string_of_playlist_token toks)
        (string_of_playlist_token h)
    ))

let lookahead toks = 
    match toks with
    [] -> (raise (ParseError "No Tokens"))
  | h::_ -> h

(* --This function relies on setting state in the filter object--
 * Parses toks until TOK_NULL is reached.
 * Sets filter object set with data from each parsed token.
 * Returns list of toks yet to be consumed.
 *)
let rec parse_filter_attributes (filter : filter_cl) (toks : playlist_token list) : playlist_token list = 
    let l = lookahead toks in
    match l with
        (Tok_Time_Begin x) ->
            let t = match_playlist_token toks (Tok_Time_Begin x) in
            filter#set_time_begin x;
            parse_filter_attributes filter t
        | (Tok_Time_End x) ->
            let t = match_playlist_token toks (Tok_Time_End x) in
            filter#set_time_end x;
            parse_filter_attributes filter t
        | (Tok_Agby x) ->
            (* 
             * The way the grammar is written, this should
             * be parsed in its own fcn. Since there's only one value for now,
             * (track_id) leave it like this.
             *)
            let t = match_playlist_token toks (Tok_Agby x) in
            filter#set_agby x;
            parse_filter_attributes filter t
        | (Tok_Limit x) ->
            let t = match_playlist_token toks (Tok_Limit x) in
            filter#set_limit x;
            parse_filter_attributes filter t
        | (Tok_Saved) ->
            let t = match_playlist_token toks (Tok_Saved) in
            (* Set to true value *)
            filter#set_saved "1";
            parse_filter_attributes filter t
        | (Tok_Count x) ->
            let t = match_playlist_token toks (Tok_Count x) in
            filter#set_count x;
            parse_filter_attributes filter t
        | (Tok_Comparator x) ->
            let t = match_playlist_token toks (Tok_Comparator x) in
            filter#set_comparator x;
            parse_filter_attributes filter t
        | (Tok_Release_Start x) ->
            let t = match_playlist_token toks (Tok_Release_Start x) in
            filter#set_release_start x;
            parse_filter_attributes filter t
        | (Tok_Release_End x) ->
            let t = match_playlist_token toks (Tok_Release_End x) in
            filter#set_release_end x;
            parse_filter_attributes filter t
        | (Tok_Filter_End) ->
            (* All filters tokens are parsed, consume Tok_Filter_End and we're done here. *)
            match_playlist_token toks (Tok_Filter_End)
        | _ -> raise (ParseError "no match on tokens which compose a filter")

let rec parse_filter (toks : playlist_token list) : (filter * playlist_token list) =
    let l = lookahead toks in
    match l with
        (Tok_Filter) ->
            let t = match_playlist_token toks Tok_Filter in
            let f = new filter_cl in
            let t' = parse_filter_attributes f t in
            (Filter(f), t')
        | _ -> raise (ParseError "no Tok_Filter token")

let rec parse_playlist_MP (toks : playlist_token list) : (playlist_expr * playlist_token list) =
    let l = lookahead toks in
    match l with
        (Tok_Playlist) ->
            let t = match_playlist_token toks Tok_Playlist in
            let filter, t' = parse_filter t in

            Playlist (filter), t'

        | _ -> raise (ParseError "no Tok_Playlist token")

let rec parse_playlist_Diff (toks : playlist_token list) : (playlist_expr * playlist_token list) =
    let (e1, t) = parse_playlist_MP toks in
    let l = lookahead t in
    match l with 
        (Tok_Diff) -> 
            let t' = match_playlist_token t Tok_Diff in
            let (e2, t'') = parse_playlist_Diff t' in
            Playlist_Diff (e1, e2), t''
        | _ -> 
            (e1, t)

let rec parse_playlist_And (toks : playlist_token list) : (playlist_expr * playlist_token list) =
    let (e1, t) = parse_playlist_Diff toks in
    let l = lookahead t in
    match l with 
        (Tok_And) -> 
            let t' = match_playlist_token t Tok_And in
            let (e2, t'') = parse_playlist_And t' in
            Playlist_And (e1, e2), t''
        | _ -> 
            (e1, t)

let rec parse_playlist_Or (toks : playlist_token list) : (playlist_expr * playlist_token list) =
    let (e1, t) = parse_playlist_And toks in
    let l = lookahead t in
    match l with 
        (Tok_Or) -> 
            let t' = match_playlist_token t Tok_Or in
            let (e2, t'') = parse_playlist_Or t' in
            Playlist_Or (e1, e2), t''
        | _ -> 
            (e1, t)

let rec parse_playlist_expr (toks : playlist_token list) : (playlist_expr * playlist_token list) =
    let (ast, t) = parse_playlist_Or toks in

    (* Token stream should end with Tok_End by definition. *)
    let t' = match_playlist_token t Tok_End in
    (* TODO: throw exception if t' still has tokens *)
    (ast, t')
