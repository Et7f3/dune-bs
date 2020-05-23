let ok = ref false

let () =
  match Sys.argv with
    [|_; "-config"|] ->
        let () = ok := true in
        Lib.config ()
  | av ->
          let () = ok := true in
    let bsc =
      let open Filename in
      let up path = concat path ".." in
      concat (Sys.getcwd () |> up |> up |> up |> up |> up |> up)"node_modules/bs-platform/linux/bsc.exe" in
    let output_file_name, av = Lib.correct_args av in
    let () = av.(0) <- bsc in
    let (bs_stdout, _bs_stdin, bs_stderr) = Unix.open_process_args_full bsc av [||] in
    let out = open_out (output_file_name ^ ".js") in
    let () = print_endline ("bsc: " ^ bsc) in
    let () = Printf.printf "output_file_name: %s\n" output_file_name in
    let () = Printf.printf "cd %s && " (Sys.getcwd ()) in
    let () = Array.iter (fun e -> Printf.printf "%s %!" e) av in
    let rec loop () =
        try
            let line = input_line bs_stdout ^ "\n" in
            let () = Lib.my_print_endline line in
            let () = output_string out line in
            loop ()
        with End_of_file  -> close_out out
    in
    let () = loop () in
    let rec loop () =
        try
            let () = output_string stderr ((input_line bs_stderr) ^ "\n") in
            loop ()
        with End_of_file -> ()
    in Unix.rename output_file_name (Filename.remove_extension output_file_name ^ ".cmo")

let () = Lib.my_end ()

let () =
  if not !ok then
    failwith "Not ok"
