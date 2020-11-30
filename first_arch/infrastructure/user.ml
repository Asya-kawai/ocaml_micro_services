let list store = Hashtbl.fold (fun k v acc -> (k, v) :: acc) store []
let save id name store = Hashtbl.add store id name
