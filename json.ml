open PlaylistTypes
open Yojson

(* Turn a filter object into JSON. *)
let filters_to_json (f : filter_cl) : string =
  let filter_json = 
  `Assoc [
    ("time_begin", `String f#get_time_begin);
    ("time_end", `String f#get_time_end);
    ("agby", `String f#get_agby);
    ("limit", `String f#get_limit);
    ("saved", `String f#get_saved);
    ("count", `String f#get_count);
    ("comparator", `String f#get_comparator);
    ("release_start", `String f#get_release_start);
    ("release_end", `String f#get_release_end)
  ] in

  Yojson.to_string filter_json
