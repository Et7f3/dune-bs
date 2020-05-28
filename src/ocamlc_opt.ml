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
    if Filename.extension output_file_name = ".exe" || Filename.extension output_file_name = ".bc" then
        open_out output_file_name |> close_out
    else
    let () = av.(0) <- bsc in
    let (bs_stdout, _bs_stdin, bs_stderr) = Unix.open_process_args_full bsc av [||] in
    let output_file_name = Filename.remove_extension output_file_name in
    let output_file_name = output_file_name ^ ".js" in
    let out = open_out output_file_name in
    let () = print_endline ("bsc: " ^ bsc) in
    let () = Printf.printf "output_file_name: %s\n" output_file_name in
    let () = Printf.printf "cd %s && " (Sys.getcwd ()) in
    let () = Array.iter (fun e -> Printf.printf "%s %!" e) av in
    let () = output_char stdout '\n' in
    let rec loop () =
        try
            let line = really_input_string bs_stdout 1 in
            let () = Lib.my_print_endline line in
            let () = print_string line in
            let () = output_string out line in
            loop ()
        with End_of_file  -> close_out out
    in
    let () = loop () in
    let error = ref false in
    let rec loop () =
        try
            let err_line = really_input_string bs_stderr 1 in
            let () = Lib.my_prerr_endline err_line in
            let () = print_endline "Hy\n\n\n\n" in
            let () = output_string stderr err_line in
            let () = error := true in
            loop ()
        with End_of_file -> ()
    in let () = Printf.printf "error: %b%!" !error in
    if not !error then
        Unix.link output_file_name (Filename.remove_extension output_file_name ^ ".cmo")
    else
        let () = prerr_endline "failure\n\n" in
        exit (-1)

let () = Lib.my_end ()

let () =
  if not !ok then
    failwith "Not ok"
