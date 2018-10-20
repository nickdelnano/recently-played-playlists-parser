open PlaylistTypes
open Common
exception EvalError of string


let rec eval_playlist_expr e songs user_id = 
    match e with
    | Playlist_Or(x,y) ->
        let s1 = List.fold_right SS.add (eval_playlist_expr x [] user_id) SS.empty in
        let s2 = List.fold_right SS.add (eval_playlist_expr y [] user_id) SS.empty in
        SS.elements (SS.union s1 s2)
    | Playlist_And(x,y) ->
        let s1 = List.fold_right SS.add (eval_playlist_expr x [] user_id) SS.empty in
        let s2 = List.fold_right SS.add (eval_playlist_expr y [] user_id) SS.empty in
        SS.elements (SS.inter s1 s2)
    | AndNot(x,y) ->
        let s1 = List.fold_right SS.add (eval_playlist_expr x [] user_id) SS.empty in
        let s2 = List.fold_right SS.add (eval_playlist_expr y [] user_id) SS.empty in
        SS.elements (SS.diff s1 s2)
    | MP(filter) ->
        match filter with
        Filter(f) ->

          let query = format_of_string "
        SELECT * FROM
          (
            SELECT 
              COUNT(*) as num_plays, 
              track_id as id 
                FROM songs_played 
                  WHERE user_id = %s AND 
                    played_at > %s AND
                    played at < %s

                  GROUP BY (track_id) 
                  ORDER BY num_plays DESC
          ) t1
        INNER JOIN tracks using (id);
        " in

          let q = Printf.sprintf query user_id (f#get_time_begin) (f#get_time_end) in
          print_string q;
          ["hi"]
