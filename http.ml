open Lwt
open Cohttp
open Cohttp_lwt_unix

let send_post url a =
  let body = `String "hello" in
    Client.get (Uri.of_string url) >>= fun (resp, body) ->
        let code = resp |> Response.status |> Code.code_of_status in
          Printf.printf "Response code: %d\n" code;
            Printf.printf "Headers: %s\n" (resp |> Response.headers |> Header.to_string);
              body |> Cohttp_lwt.Body.to_string >|= fun body ->
                  Printf.printf "Body of length: %d\n" (String.length body);
                    body

let () =
    let body_str = "hello" in
    let b = (Cohttp_lwt.Body.of_string body_str) in
    let body = Lwt_main.run (send_post "http://localhost:8888/process_filter?q=laaaaa" b) in
      print_endline ("Received body\n" ^ body)
