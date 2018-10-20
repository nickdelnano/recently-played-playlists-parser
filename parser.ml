open PlaylistTypes
open Utils
exception ParseError of string

(* Provided helper function - takes a token list and an exprected token.
 * Handles error cases and returns the tail of the list *)
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

let rec parse_PreAgFilter pre_filter toks = 
    let l = lookahead toks in
    match l with
        (Tok_Begin x) ->
            let t' = match_playlist_token toks (Tok_Begin x) in
            pre_filter#set_begin x;
            parse_PreAgFilter pre_filter t'
        | (Tok_End x) ->
            let t' = match_playlist_token toks (Tok_End x) in
            pre_filter#set_end x;
            parse_PreAgFilter pre_filter t'
        | (Tok_Agby x) ->
            (* 
             * The way the grammar is written, this should
             * be parsed in its own fcn. Since there's only one value for now,
             * leave it like this.
             *)
            let t' = match_playlist_token toks (Tok_Agby x) in
            pre_filter#set_agby x;
            parse_PreAgFilter pre_filter t'
        | (Tok_Limit x) ->
            let t' = match_playlist_token toks (Tok_Limit x) in
            pre_filter#set_limit x;
            parse_PreAgFilter pre_filter t'
        | (Tok_Null) ->
            (* All pre ag filters are parsed, return the fully set object *)
            let t' = match_playlist_token toks (Tok_Null) in
            pre_filter, t'
        | _ -> raise (ParseError "no match on pre ag filter")

let rec parse_PostAgFilter post_filter toks = 
    let l = lookahead toks in
    match l with
        | (Tok_Saved) ->
            let t' = match_playlist_token toks (Tok_Saved) in
            post_filter#set_saved 1;
            parse_PostAgFilter post_filter t'
        | (Tok_Count x) ->
            let t' = match_playlist_token toks (Tok_Count x) in
            post_filter#set_count x;
            parse_PostAgFilter post_filter t'
        | (Tok_Comparator x) ->
            let t' = match_playlist_token toks (Tok_Comparator x) in
            post_filter#set_comparator x;
            parse_PostAgFilter post_filter t'
        | (Tok_Release_Start x) ->
            let t' = match_playlist_token toks (Tok_Release_Start x) in
            post_filter#set_release_start x;
            parse_PostAgFilter post_filter t'
        | (Tok_Release_End x) ->
            let t' = match_playlist_token toks (Tok_Release_End x) in
            post_filter#set_release_end x;
            parse_PostAgFilter post_filter t'
        | (Tok_Null) ->
            (* All post ag filters are parsed, return the fully set object *)
            let t' = match_playlist_token toks (Tok_Null) in
            post_filter, t'
        | _ -> raise (ParseError "no match on post ag filter")

let rec parse_playlist_MP toks = 
    let l = lookahead toks in
    match l with
        (Tok_MP) ->
            let t' = match_playlist_token toks Tok_MP in
            let p = new pre_ag_filter_cl in
            let p' = new post_ag_filter_cl in
            let (pre_filters, t'') = parse_PreAgFilter p t' in
            let (post_filters, tt') = parse_PostAgFilter p' t'' in

            MP (Filter(pre_filters), Filter(post_filters)), tt'

        | _ -> raise (ParseError "no Tok_MP before filters begin")

let rec parse_playlist_And_Not toks = 
    let (e1, t) = parse_playlist_MP toks in
    let l = lookahead t in
    match l with 
        (Tok_And_Not) -> 
            let t' = match_playlist_token t Tok_And_Not in
            let (e2, t'') = parse_playlist_And_Not t' in
            AndNot (e1, e2), t''
        | _ -> 
            (e1, t)

let rec parse_playlist_And toks = 
    let (e1, t) = parse_playlist_And_Not toks in
    let l = lookahead t in
    match l with 
        (Tok_And) -> 
            let t' = match_playlist_token t Tok_And in
            let (e2, t'') = parse_playlist_And t' in
            Playlist_And (e1, e2), t''
        | _ -> 
            (e1, t)

let rec parse_playlist_Or toks = 
    let (e1, t) = parse_playlist_And toks in
    let l = lookahead t in
    match l with 
        (Tok_Or) -> 
            let t' = match_playlist_token t Tok_Or in
            let (e2, t'') = parse_playlist_Or t' in
            Playlist_Or (e1, e2), t''
        | _ -> 
            (e1, t)

let rec parse_playlist_expr toks = 
    let (e1, t) = parse_playlist_Or toks in
    (t, e1)
