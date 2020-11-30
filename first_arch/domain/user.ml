let list list_func store =
  let tuple_list = list_func store in
  (* return "[{...}...]" *)
  List.fold_left (fun str (x, y) -> str ^ (Printf.sprintf "{ id: %d, name: %s }," x y))
    "[" tuple_list ^ "]"
let add add_func id name store = begin
    add_func id name store;
    Printf.sprintf "{ id: %d, name: %s }" id name
  end
