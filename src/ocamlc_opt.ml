let ok = ref false

let () =
  match Sys.argv with
    [|_; "-config"|] ->
        let () = ok := true in
        Lib.config ()
  | av ->
    let av = Lib.correct_args av in
    let rec loop i l =
        let () = print_endline av.(i) in
      if av.(i) = "-o" then
          let () = ok := true in
          open_out (av.(i+1)) |> close_out
      else if i + 1 < l then
          loop (i + 1) l
    in loop 1 (Array.length av)

let () = Lib.my_end ()

let () =
  if not !ok then
    failwith "Not ok"
