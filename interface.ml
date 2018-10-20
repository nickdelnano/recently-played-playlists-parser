open Utils;;
open PlaylistTypes;;

(* TODO fix usage docs and add support for lexer*)
let print_usage () =
  print_string "\nThis file functions as a driver for interfacing with the playlist-[lexer|parser].\n\n";
  print_string "Usage:\n";
  print_string "\t./interface <mode> <filename>: Run your parser and lexer on standard input, or a file if one is provided.\n";
  print_string "Modes:\n";
  print_string "\tlex: Run in lex mode to show the tokens output by your lexer\n";
  print_string "\tparse_expr: Parse an expression using parse_playlist_expr\n";
;;

if Array.length Sys.argv < 2 then begin print_usage (); exit 1 end;;


 let toks = [Tok_MP; Tok_Filter; Tok_Time_Begin("1"); Tok_Time_End("2"); Tok_Agby("song_id"); Tok_Limit("5"); Tok_Release_Start("10"); Tok_Release_End("50"); Tok_Filter_End; Tok_And_Not; Tok_MP; Tok_Filter; Tok_Agby("song_id"); Tok_Saved; Tok_Comparator("1"); Tok_Count("10"); Tok_Filter_End; Tok_End];;

match Sys.argv.(1) with
| "lex" ->
  print_string @@ string_of_list ~newline:true string_of_playlist_token toks
| "parse_playlist_expr" ->
  let (remaining, e) = Parser.parse_playlist_expr toks in
  print_string @@ string_of_playlist_expr e;

  print_string ("\nRemaining tokens: " ^ (string_of_list ~newline:true string_of_playlist_token remaining));

  let playlist = Eval.eval_playlist_expr e [] "15" in
  print_string "done!"

| _ ->
  raise (InvalidInputException("What are you trying to do?"))
;;
