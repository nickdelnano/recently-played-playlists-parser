open Lwt
open Cohttp
open Cohttp_lwt_unix

open Yojson

let call_post_endpoint uri post_body =
  Client.post (Uri.of_string uri) ~body:(Cohttp_lwt__Body.of_string post_body) >>= fun (resp, body) ->
    let code = resp |> Response.status |> Code.code_of_status in
    Printf.printf "Response code: %d\n" code;
    Printf.printf "Headers: %s\n" (resp |> Response.headers |> Header.to_string);
    body |> Cohttp_lwt.Body.to_string >|= fun body ->
    Printf.printf "Body of length: %d\n" (String.length body);
    body

let () =
  let data = "data for post" in
  let body = Lwt_main.run (call_post_endpoint "http://localhost:5000/test" data) in
  print_endline ("Received body\n" ^ body)
