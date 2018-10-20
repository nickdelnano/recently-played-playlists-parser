open Yojson

let filters_to_json filter : json =
  `Assoc [
    ("time_begin", `String filter#get_time_begin),
    ("time_end", `String filter#get_time_end),
    ("agby", `String filter#get_agby),
    ("limit", `String filter#get_limit),
    ("saved", `String filter#get_saved),
    ("count", `String filter#get_count),
    ("comparator", `String filter#get_comparator),
    ("release_start", `String filter#get_release_start),
    ("release_end", `String filter#get_release_end)
  ]

let person = `Assoc [ ("name", `String "Anil") ];;
print_string (Yojson.Basic.pretty_to_string person);;
