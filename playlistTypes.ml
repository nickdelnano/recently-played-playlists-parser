exception InvalidInputException of string

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
  | Tok_Count of string
  | Tok_Limit of string
  | Tok_Comparator of string
  | Tok_Saved
  | Tok_End
  (* Forcing assocativity not supported, yet. Should be eazy.
  | Tok_RParen
  | Tok_LParen
  *)

class filter_cl =
  object (self)
    (* Earliest UTC*)
    val mutable time_begin = ( "0" : string )
    (* Latest UTC -- 11 digits *)
    val mutable time_end = ( "99999999999" : string )
    (* Only track_id for now *)
    val mutable agby = ( "track_id" : string )
    val mutable limit = ( "-1" : string )
    (* saved won't be implemented until I figure out
     * how I want to handle implementing spotify api client in ocaml
     * or doing something funky by calling out to the php code
     * I already have. *)
    (* 0: false, 1: true*)
    val mutable saved = ( "0" : string )
    val mutable count = ( "-1" : string )
    (* 0: <, 1: <=, 2: >, 3: >=*)
    val mutable comparator = ( "-1" : string )
    (* Earliest UTC*)
    val mutable release_start = ( "0" : string )
    (* Latest UTC -- 11 digits *)
    val mutable release_end = ( "99999999999" : string )

    (* getters *)
    method get_time_begin : string = 
      time_begin
    method get_time_end : string = 
      time_end
    method get_agby : string = 
      agby
    method get_limit : string = 
      limit
    method get_saved : string = 
      saved
    method get_count : string = 
      count
    method get_comparator : string = 
      comparator
    method get_release_start : string = 
      release_start
    method get_release_end : string = 
      release_end

    (* setters *)
    method set_time_begin x = 
      time_begin <- x
    method set_time_end x = 
      time_end <- x
    method set_agby x = 
      agby <- x
    method set_limit x = 
      limit <- x
    method set_saved x = 
      saved <- x
    method set_count x = 
      count <- x
    method set_comparator x = 
      comparator <- x
    method set_release_start x = 
      release_start <- x
    method set_release_end x = 
      release_end <- x
  end

type filter =
  Filter of filter_cl

type playlist_expr = 
  | Playlist of filter
  | Playlist_Or of playlist_expr * playlist_expr
  | Playlist_And of playlist_expr * playlist_expr
  (* playlist a - playlist b *)
  | Playlist_Diff of playlist_expr * playlist_expr
