(** Don't open at global
  Reference: https://medium.com/@huund/do-not-open-6e5d3070c118
*)

let server =
  let user_data_store = Hashtbl.create 100 in
  let current_user_id = ref 0 in
  (* Initial settings *)
  let open Lwt in
  (* Create callback function *)
  let callback _conn req body =
    let uri = req |> Cohttp.Request.uri |> Uri.to_string in
    let meth = req |> Cohttp.Request.meth |> Cohttp.Code.string_of_method in
    let headers = req |> Cohttp.Request.headers |> Cohttp.Header.to_string in
    match (uri,meth) with
    (* User service *)
    | ("//localhost:8000/users", "GET") ->
       Cohttp_lwt_unix.Server.respond_string
         ~status:`OK
         ~body: (Domain.User.list Infrastructure.User.list user_data_store) ()
    | ("//localhost:8000/users", "POST") ->
       body |> Cohttp_lwt.Body.to_string >|= Yojson.Basic.from_string >>= (fun body ->
        let open Yojson.Basic.Util in
        let name = body |> member "name" |> to_string in
        begin
          current_user_id := !current_user_id + 1;
          Cohttp_lwt_unix.Server.respond_string
            ~status:`OK
            ~body: (Domain.User.add Infrastructure.User.save !current_user_id name user_data_store) ()
        end)
    (* Mail service *)
    | ("//localhost:8000/mails", "POST") ->
       Cohttp_lwt_unix.Server.respond_string
         ~status:`OK
         ~body: (Domain.Mail.send ()) ()
    (* Default *)
    | (_, _) -> body |> Cohttp_lwt.Body.to_string >|= (fun body ->
        Printf.sprintf "Not found, Debug message ==> Uri: %s\nMethod: %s\nHeaders\nHeaders: %s\nBody: %s"
          uri meth headers body)
           >>= (fun body -> Cohttp_lwt_unix.Server.respond_string ~status:`OK ~body ())
  in
  Cohttp_lwt_unix.Server.create ~mode:(`TCP (`Port 8000)) (Cohttp_lwt_unix.Server.make ~callback ())

let () = ignore (Lwt_main.run server)
