open Utils
open OUnit2
open PlaylistTypes

exception PlaylistTypeNotFound of string

(* Parse a simple one level Playlist with its filter. *)
let test_parse_simple_playlist_with_all_filter_attributes_set ctxt = 
    let time_begin = "100000000" in
    let time_end = "200000000" in
    let agby = "track_id" in
    let limit = 100 in
    let saved = 0 in
    let count = 5 in
    let comparator = 3 in
    let rel_start = "300000000" in
    let rel_end = "400000000" in

    let toks = [Tok_Playlist; Tok_Time_Begin(time_begin); Tok_Time_End(time_end); Tok_Agby(agby); Tok_Limit(limit); Tok_Saved(saved); Tok_Count(count); Tok_Comparator(comparator); Tok_Release_Start(rel_start); Tok_Release_End(rel_end); Tok_Filter_End; Tok_End] in

    let (ast, leftover_toks) = Parser.parse_playlist_expr toks in

    (* All tokens are parsed *)
    assert_equal [] leftover_toks;

    (* Assertions on filter for the single playlist *)
    match ast with
    | Playlist(filter) ->
        (match filter with
        Filter(f) ->
            assert_equal f#get_time_begin time_begin;
            assert_equal f#get_time_end time_end;
            assert_equal f#get_agby agby;
            assert_equal f#get_limit limit;
            assert_equal f#get_saved saved;
            assert_equal f#get_count count;
            assert_equal f#get_comparator comparator;
            assert_equal f#get_release_start rel_start;
            assert_equal f#get_release_end rel_end;
            )
    | _ -> raise (PlaylistTypeNotFound "simple playlist parse did not return a Playlist type")

(* Parse a simple one level Playlist with its filter. *)
let test_parse_and_playlist_with_all_filter_attributes_set ctxt = 
    let time_begin = "100000000" in
    let time_end = "200000000" in
    let agby = "track_id" in
    let limit = 100 in
    let saved = 0 in
    let count = 5 in
    let comparator = 3 in
    let rel_start = "300000000" in
    let rel_end = "400000000" in

    let time_begin1 = "200000000" in
    let time_end1 = "300000000" in
    (* album_id isn't supported, this exists to be different than the other playlists's agby *)
    let agby1 = "album_id" in
    let limit1 = 200 in
    let saved1 = 1 in
    let count1 = 6 in
    let comparator1 = 3 in
    let rel_start1 = "400000000" in
    let rel_end1 = "500000000" in

    let toks = [
        Tok_Playlist; Tok_Time_Begin(time_begin); Tok_Time_End(time_end); Tok_Agby(agby); Tok_Limit(limit); Tok_Saved(saved); Tok_Count(count); Tok_Comparator(comparator); Tok_Release_Start(rel_start); Tok_Release_End(rel_end); Tok_Filter_End; 

        Tok_And;

        Tok_Playlist; Tok_Time_Begin(time_begin1); Tok_Time_End(time_end1); Tok_Agby(agby1); Tok_Limit(limit1); Tok_Saved(saved1); Tok_Count(count1); Tok_Comparator(comparator1); Tok_Release_Start(rel_start1); Tok_Release_End(rel_end1); Tok_Filter_End; 
    
    Tok_End] in

    let (ast, leftover_toks) = Parser.parse_playlist_expr toks in

    (* All tokens are parsed *)
    assert_equal [] leftover_toks;

    (* Assertions on filter for the single playlist *)
    match ast with
    | Playlist_And(p, p1) ->
        (match p with
        Playlist(filter) ->
            (match filter with
            Filter(f) ->
                assert_equal f#get_time_begin time_begin;
                assert_equal f#get_time_end time_end;
                assert_equal f#get_agby agby;
                assert_equal f#get_limit limit;
                assert_equal f#get_saved saved;
                assert_equal f#get_count count;
                assert_equal f#get_comparator comparator;
                assert_equal f#get_release_start rel_start;
                assert_equal f#get_release_end rel_end;
            )
        | _ -> raise (PlaylistTypeNotFound "This match statement should only ever match a Playlist")
        );
        (match p1 with
        Playlist(filter) ->
            (match filter with
            Filter(f) ->
                assert_equal f#get_time_begin time_begin1;
                assert_equal f#get_time_end time_end1;
                assert_equal f#get_agby agby1;
                assert_equal f#get_limit limit1;
                assert_equal f#get_saved saved1;
                assert_equal f#get_count count1;
                assert_equal f#get_comparator comparator1;
                assert_equal f#get_release_start rel_start1;
                assert_equal f#get_release_end rel_end1;
            )
        | _ -> raise (PlaylistTypeNotFound "This match statement should only ever match a Playlist")
        )
    | _ -> raise (PlaylistTypeNotFound "parse did not return a Playlist_And type")

(* Copy and paste of test_parse_and_playlist_with_all_filter_attributes_set , but replacing Tok_And with Tok_Or *)
let test_parse_or_playlist_with_all_filter_attributes_set ctxt = 
    let time_begin = "100000000" in
    let time_end = "200000000" in
    let agby = "track_id" in
    let limit = 100 in
    let saved = 0 in
    let count = 5 in
    let comparator = 3 in
    let rel_start = "300000000" in
    let rel_end = "400000000" in

    let time_begin1 = "200000000" in
    let time_end1 = "300000000" in
    (* album_id isn't supported, this exists to be different than the other playlists's agby *)
    let agby1 = "album_id" in
    let limit1 = 200 in
    let saved1 = 1 in
    let count1 = 6 in
    let comparator1 = 3 in
    let rel_start1 = "400000000" in
    let rel_end1 = "500000000" in

    let toks = [
        Tok_Playlist; Tok_Time_Begin(time_begin); Tok_Time_End(time_end); Tok_Agby(agby); Tok_Limit(limit); Tok_Saved(saved); Tok_Count(count); Tok_Comparator(comparator); Tok_Release_Start(rel_start); Tok_Release_End(rel_end); Tok_Filter_End; 

        Tok_Or;

        Tok_Playlist; Tok_Time_Begin(time_begin1); Tok_Time_End(time_end1); Tok_Agby(agby1); Tok_Limit(limit1); Tok_Saved(saved1); Tok_Count(count1); Tok_Comparator(comparator1); Tok_Release_Start(rel_start1); Tok_Release_End(rel_end1); Tok_Filter_End;
        
    Tok_End] in

    let (ast, leftover_toks) = Parser.parse_playlist_expr toks in

    (* All tokens are parsed *)
    assert_equal [] leftover_toks;

    (* Assertions on filter for the single playlist *)
    match ast with
    | Playlist_Or(p, p1) ->
        (match p with
        Playlist(filter) ->
            (match filter with
            Filter(f) ->
                assert_equal f#get_time_begin time_begin;
                assert_equal f#get_time_end time_end;
                assert_equal f#get_agby agby;
                assert_equal f#get_limit limit;
                assert_equal f#get_saved saved;
                assert_equal f#get_count count;
                assert_equal f#get_comparator comparator;
                assert_equal f#get_release_start rel_start;
                assert_equal f#get_release_end rel_end;
            )
        | _ -> raise (PlaylistTypeNotFound "This match statement should only ever match a Playlist")
        );
        (match p1 with
        Playlist(filter) ->
            (match filter with
            Filter(f) ->
                assert_equal f#get_time_begin time_begin1;
                assert_equal f#get_time_end time_end1;
                assert_equal f#get_agby agby1;
                assert_equal f#get_limit limit1;
                assert_equal f#get_saved saved1;
                assert_equal f#get_count count1;
                assert_equal f#get_comparator comparator1;
                assert_equal f#get_release_start rel_start1;
                assert_equal f#get_release_end rel_end1;
            )
        | _ -> raise (PlaylistTypeNotFound "This match statement should only ever match a Playlist")
        )
    | _ -> raise (PlaylistTypeNotFound "parse did not return a Playlist_Or type")

(* Copy and paste of test_parse_and_playlist_with_all_filter_attributes_set , but replacing Tok_And with Tok_Diff *)
let test_parse_diff_playlist_with_all_filter_attributes_set ctxt = 
    let time_begin = "100000000" in
    let time_end = "200000000" in
    let agby = "track_id" in
    let limit = 100 in
    let saved = 0 in
    let count = 5 in
    let comparator = 3 in
    let rel_start = "300000000" in
    let rel_end = "400000000" in

    let time_begin1 = "200000000" in
    let time_end1 = "300000000" in
    (* album_id isn't supported, this exists to be different than the other playlists's agby *)
    let agby1 = "album_id" in
    let limit1 = 200 in
    let saved1 = 1 in
    let count1 = 6 in
    let comparator1 = 3 in
    let rel_start1 = "400000000" in
    let rel_end1 = "500000000" in

    let toks = [
        Tok_Playlist; Tok_Time_Begin(time_begin); Tok_Time_End(time_end); Tok_Agby(agby); Tok_Limit(limit); Tok_Saved(saved); Tok_Count(count); Tok_Comparator(comparator); Tok_Release_Start(rel_start); Tok_Release_End(rel_end); Tok_Filter_End; 

        Tok_Diff;

        Tok_Playlist; Tok_Time_Begin(time_begin1); Tok_Time_End(time_end1); Tok_Agby(agby1); Tok_Limit(limit1); Tok_Saved(saved1); Tok_Count(count1); Tok_Comparator(comparator1); Tok_Release_Start(rel_start1); Tok_Release_End(rel_end1); Tok_Filter_End;
        
    Tok_End] in

    let (ast, leftover_toks) = Parser.parse_playlist_expr toks in

    (* All tokens are parsed *)
    assert_equal [] leftover_toks;

    (* Assertions on filter for the single playlist *)
    match ast with
    | Playlist_Diff(p, p1) ->
        (match p with
        Playlist(filter) ->
            (match filter with
            Filter(f) ->
                assert_equal f#get_time_begin time_begin;
                assert_equal f#get_time_end time_end;
                assert_equal f#get_agby agby;
                assert_equal f#get_limit limit;
                assert_equal f#get_saved saved;
                assert_equal f#get_count count;
                assert_equal f#get_comparator comparator;
                assert_equal f#get_release_start rel_start;
                assert_equal f#get_release_end rel_end;
            )
        | _ -> raise (PlaylistTypeNotFound "This match statement should only ever match a Playlist")
        );
        (match p1 with
        Playlist(filter) ->
            (match filter with
            Filter(f) ->
                assert_equal f#get_time_begin time_begin1;
                assert_equal f#get_time_end time_end1;
                assert_equal f#get_agby agby1;
                assert_equal f#get_limit limit1;
                assert_equal f#get_saved saved1;
                assert_equal f#get_count count1;
                assert_equal f#get_comparator comparator1;
                assert_equal f#get_release_start rel_start1;
                assert_equal f#get_release_end rel_end1;
            )
        | _ -> raise (PlaylistTypeNotFound "This match statement should only ever match a Playlist")
        )
    | _ -> raise (PlaylistTypeNotFound "parse did not return a Playlist_Diff type")

    
let suite =
  "public" >::: [
      "test_simple_playlist" >:: test_parse_simple_playlist_with_all_filter_attributes_set;
      "test_and_playlist" >:: test_parse_and_playlist_with_all_filter_attributes_set;
      "test_or_playlist" >:: test_parse_or_playlist_with_all_filter_attributes_set;
      "test_diff_playlist" >:: test_parse_diff_playlist_with_all_filter_attributes_set
  ]

let _ = run_test_tt_main suite
