let find key (yml : Yaml.value) = match yml with
  | `O assoc -> List.assoc_opt key assoc
  | _ -> None

(* --- *)

let () =
  if Array.length Sys.argv != 2 then
    ()
  else
    (* let command = Sys.argv.(0) in *)
    let yaml_file = Sys.argv.(1) in
    let yaml_body = Yaml_unix.of_file_exn Fpath.(v yaml_file) in
    (* Printf.printf "%s" (Yaml.to_string_exn yaml_body) *)
    let spec = match find "spec" yaml_body with
      | Some x -> x
      | None -> Yaml.of_string_exn ""
    in
    let template = match find "template" spec with
      | Some x -> x
      | None -> Yaml.of_string_exn ""
    in    
    let metadata = match find "metadata" template with
      | Some x -> x
      | None -> Yaml.of_string_exn ""
    in
    let labels = match find "labels" metadata with
      | Some x -> x
      | None -> Yaml.of_string_exn ""
    in
    (* Printf.printf "%s" (Yaml.to_string_exn labels) *)
    let instance = match find "app.kubernetes.io/name" labels with
    | Some x -> x
    | None -> Yaml.of_string_exn ""
    in
    let rec show infrastructure_layer domain_layer interface_layer instance = match Str.split (Str.regexp "/") instance with
      | [] ->
         let d = List.fold_left (fun str x -> str ^ (Printf.sprintf "%s," x)) "Infrastructures: [ " infrastructure_layer ^ " ]" in 
         let inf = List.fold_left (fun str x -> str ^ (Printf.sprintf "%s," x)) "Domains: [ " domain_layer ^ " ]" in
         let infr = List.fold_left (fun str x -> str ^ (Printf.sprintf "%s," x)) "Interfaces: [ " interface_layer ^ " ]" in
         Printf.printf "%s\n%s\n%s\n" d inf infr
      | x :: [] -> show infrastructure_layer (x :: domain_layer) interface_layer ""
      | x :: y :: [] -> show infrastructure_layer (y :: domain_layer) (x :: interface_layer) ""
      | x :: y -> show infrastructure_layer domain_layer (x :: interface_layer) (String.concat "/" y)
    in show [] [] [] (String.trim (Yaml.to_string_exn instance))
    
    
