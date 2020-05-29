let ok = ref false

let () =
  match Sys.argv with
    [|_; "-config"|] ->
        let () = ok := true in
        Lib.config ()
  | real_av ->
          let () = ok := true in
    let bsc =
      let open Filename in
      let up path = concat path ".." in
      concat (Sys.getcwd () |> up |> up |> up |> up |> up |> up)"node_modules/bs-platform/linux/bsc.exe" in
    let output_file_name, av = Lib.correct_args real_av in
    if Filename.(output_file_name |> dirname |> dirname = ".ppx") then
        let () = real_av.(0) <- Filename.("ocamlc.opt" |> concat "bin" |> concat Lib.standard_library_path) in
        let () = Printf.printf "cd %s && " (Sys.getcwd ()) in
        let () = Array.iter (fun e -> Printf.printf "%s %!" e) real_av in
        let () = output_char stdout '\n' in
        let () = Printf.printf "REAL_OCAML_PATH=%s\n%!" real_av.(0) in
        (*let real_av = [| "/usr/bin/bash"; "-i" |] in *)
        let (ocaml_stdout, ocaml_stdin, ocaml_stderr) = Unix.open_process_args_full real_av.(0) real_av (Unix.environment ()) in
        (*let () = output_string ocaml_stdin " set\n" in
        let () = output_string ocaml_stdin " which ld; echo $?\n" in
        *)let () = close_out ocaml_stdin in
        let () =
          let rec loop () =
            let () = print_endline (input_line ocaml_stdout) in
            loop ()
          in
          try loop ()
          with End_of_file -> close_in ocaml_stdout in
        let () =
          let rec loop () =
            let () = print_endline (input_line ocaml_stderr) in
            loop ()
          in
          try loop ()
          with End_of_file -> close_in ocaml_stderr in
        exit 0
    else
    let () = av.(0) <- bsc in
    if Filename.extension output_file_name = ".exe" || Filename.extension output_file_name = ".bc" || Filename.extension output_file_name = ".cma" then
        open_out output_file_name |> close_out
    else
    let av =
        Array.mapi (fun i e ->
        if Filename.extension (Filename.remove_extension e) = ".pp" then
            let dest_name = Filename.((remove_extension e |> remove_extension) ^ ".ml") in
            let refmt = Filename.concat (bsc |> Filename.dirname) "refmt.exe" in
            let (refmt_stdout, refmt_stdin, refmt_stderr) = Unix.open_process_args_full refmt [| refmt; "--parse"; "binary"; "--print"; "ml"; e |] (Unix.environment ()) in
            let () = close_out refmt_stdin in
            let () = close_in refmt_stderr in
            let () = Unix.chmod dest_name 0o777 in
            let dest = open_out dest_name in
            let rec loop () =
                let line = input_line refmt_stdout ^ "\n" in
                let () = output_string dest line in
                let () = print_string line in
                loop ()
            in let () = try loop () with End_of_file -> close_in refmt_stdout in
            let () = close_out dest in
            let () = Printf.printf "name of file: %s\n%!" e in
            dest_name
        else
            e) av
    in
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
