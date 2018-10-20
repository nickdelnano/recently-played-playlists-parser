exception InvalidInputException of string

type playlist_token = 
  | Tok_Or
  | Tok_And
  | Tok_And_Not
  | Tok_MP
  | Tok_Null
  | Tok_Begin of int
  | Tok_End of int
  | Tok_Agby of string
  | Tok_Release_Start of int
  | Tok_Release_End of int
  | Tok_Count of int
  | Tok_Limit of int
  | Tok_Comparator of int
  | Tok_Saved
  | Tok_RParen
  | Tok_LParen

class pre_ag_filter_cl =
  object (self)
    val mutable time_begin = ( 0 : int )
    val mutable time_end = ( 0 : int )
    val mutable agby = ( "" : string )
    val mutable limit = ( -1 : int )

    method get_begin = 
      time_begin
    method get_end = 
      time_end
    method get_agby = 
      agby
    method get_limit = 
      limit

    method set_begin x = 
      time_begin <- x
    method set_end x = 
      time_end <- x
    method set_agby x = 
      agby <- x
    method set_limit x = 
      limit <- x
  end

class post_ag_filter_cl =
  object (self)
    (* saved won't be implemented until I figure out
     * how I want to handle implementing spotify api client in ocaml
     * or doing something funky by calling out to the php code
     * I already have. *)
    val mutable saved = ( 0 : int )
    val mutable count = ( -1 : int )
    val mutable comparator = ( 0 : int )
    val mutable release_start = ( 0 : int )
    val mutable release_end = ( 0 : int )
    method get_saved = 
      saved
    method get_count = 
      count
    method get_comparator = 
      comparator
    method get_release_start = 
      release_start
    method get_release_end = 
      release_end

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

type pre_ag_filter =
  Filter of pre_ag_filter_cl

type post_ag_filter =
  Filter of post_ag_filter_cl

type playlist_expr = 
  | MP of pre_ag_filter * post_ag_filter
  | Playlist_Or of playlist_expr * playlist_expr
  | Playlist_And of playlist_expr * playlist_expr
  | AndNot of playlist_expr * playlist_expr
