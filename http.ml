open Cohttp
open Cohttp_lwt_unix
open Lwt

let base_url = "http://localhost:5000";;

(* /process_filter functions *)
let build_process_filter_uri f username =
    Printf.sprintf "%s/process_filter?username=%s&time_begin=%s&time_end=%s&agby=%s&limit=%s&saved=%s&count=%s&comparator=%s&release_start=%s&release_end=%s" base_url username f#get_time_begin f#get_time_end f#get_agby (string_of_int f#get_limit) (string_of_int f#get_saved) (string_of_int f#get_count) (string_of_int f#get_comparator) f#get_release_start f#get_release_end

let get_process_filter filter username =
    let uri = build_process_filter_uri filter username in
    Client.get (Uri.of_string uri) >>= fun (resp, body) ->
        let code = resp |> Response.status |> Code.code_of_status in
          Printf.printf "Response code: %d\n" code;
              body |> Cohttp_lwt.Body.to_string >|= fun body ->
                    body

let call_process_filter_endpoint f username =
  Lwt_main.run (get_process_filter f username)

(* /make_playlist functions *)
let build_make_playlist_uri username playlist_name description =
    Printf.sprintf "%s/make_playlist?username=%s&playlist_name=%s&description=%s" base_url username playlist_name description

let post_make_playlist username playlist_name track_ids description =
    let uri = build_make_playlist_uri username playlist_name description in
    Client.post (Uri.of_string uri) ~body:(Cohttp_lwt__Body.of_string track_ids) >>= fun (resp, body) ->
        let code = resp |> Response.status |> Code.code_of_status in
        Printf.printf "Response code: %d\n" code;
              body |> Cohttp_lwt.Body.to_string >|= fun body ->
                    body

let call_make_playlist_endpoint username playlist_name track_ids description =
  Lwt_main.run (post_make_playlist username playlist_name track_ids description)
