let ok = ref true

let () =
  match Sys.argv with
    [|_; "-config"|] -> Lib.config ()
  | _ -> ok := false

let () = Lib.my_end ()

let () =
  if not !ok then
    failwith "Not ok"
