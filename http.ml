open Lwt
open Cohttp
open Cohttp_lwt_unix

let build_process_filter_uri f username =
    Printf.sprintf "http://localhost:8888/process_filter?username=%s&time_begin=%s&time_end=%s&agby=%s&limit=%s&saved=%s&count=%s&comparator=%s&release_start=%s&release_end=%s" username f#get_time_begin f#get_time_end f#get_agby f#get_limit f#get_saved f#get_count f#get_comparator f#get_release_start f#get_release_end

let process_filter filter username =
    let uri = build_process_filter_uri filter username in
    Client.get (Uri.of_string uri) >>= fun (resp, body) ->
        let code = resp |> Response.status |> Code.code_of_status in
          Printf.printf "Response code: %d\n" code;
            Printf.printf "Headers: %s\n" (resp |> Response.headers |> Header.to_string);
              body |> Cohttp_lwt.Body.to_string >|= fun body ->
                  Printf.printf "Body of length: %d\n" (String.length body);
                    body

let call_process_filter_endpoint f username =
  Lwt_main.run (process_filter f username)
