open Filename

let root = Sys.executable_name |> dirname |> dirname |> dirname |> dirname

let exec_name = basename Sys.executable_name

let conacat x y = concat x (exec_name ^ "_" ^ y)

let root_args = concat root "args"
let root_stdout = concat root "stdout"
let root_stderr = concat root "stderr"
let root_stdin = concat root "stdin"

let my_args = open_out_bin root_args
let my_stdout = open_out_bin root_stdout
let my_stderr = open_out_bin root_stderr
let my_stdin = open_in_bin root_stdin (* I'm not sure if useful *)

let my_print_endline s =
  output_string my_stdout s; output_char my_stdout '\n'; flush my_stdout

let () =
  let () =
    Array.iter
      (function e ->
        let () = output_string my_args e in
        output_char my_args '\n') Sys.argv
  in let () = flush my_args in
  close_out my_args

let my_end () =
  let () = close_out my_stdout in
  let () = close_out my_stderr in
  close_in my_stdin

