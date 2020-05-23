let ok = ref false

let () =
  match Sys.argv with
    [|_; "-config"|] ->
        let () = ok := true in
        Lib.config ()
  | av ->
    let bsc =
      let open Filename in
      let up path = concat path ".." in
      concat (Sys.getcwd () |> up |> up |> up |> up |> up |> up)"node_modules/bs-platform/linux/bsc.exe" in
    let () = print_endline ("bsc: " ^ bsc) in
    let av = Lib.correct_args av in
    let output_name = ref "" in
    let (bs_stdout, _bs_stdin, bs_stderr) = Unix.open_process_args_full bsc av [||] in
    let rec loop i l =
        let () = print_endline av.(i) in
      if av.(i) = "-o" then
          let () = ok := true in
          output_name := av.(i+1)
      else if i + 1 < l then
          loop (i + 1) l
    in let () = loop 1 (Array.length av) in
    let out = open_out !output_name in
    let () = print_endline "here" in
    let rec loop () =
        try
            let line = input_line bs_stdout ^ "\n" in
            let () = Lib.my_print_endline line in
            let () = output_string out line in
            loop ()
        with End_of_file  -> close_out out
    in
    let () = loop () in
    let () = print_endline "here" in
    let rec loop () =
        try
            let () = output_string stderr ((input_line bs_stderr) ^ "\n") in
            loop ()
        with End_of_file -> ()
    in ()

let () = Lib.my_end ()

let () =
  if not !ok then
    failwith "Not ok"
