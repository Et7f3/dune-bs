open Filename

let root = Sys.executable_name |> dirname |> dirname |> dirname |> dirname

let exec_name = basename Sys.executable_name

let concat' x y = concat x (exec_name ^ "_" ^ y)

let root_args = concat' root "args"
let root_stdout = concat' root "stdout"
let root_stderr = concat' root "stderr"
(*let root_stdin = concat root "stdin"*)

let my_args = open_out_bin root_args
let my_stdout = open_out_bin root_stdout
let my_stderr = open_out_bin root_stderr
(*let my_stdin = open_in_bin root_stdin *)(* I'm not sure if useful *)

let my_print_endline s =
  output_string my_stdout s; output_char my_stdout '\n'; flush my_stdout

let my_prerr_endline s =
  output_string my_stderr s; output_char my_stderr '\n'; flush my_stderr

let () =
  let () = Array.iter my_print_endline Sys.argv in
  let () = flush my_args in
  close_out my_args

let my_end () =
  let () = close_out my_stdout in
  let () = close_out my_stderr in
  ()(*close_in my_stdin*)

let resolve path =
    concat (Sys.getcwd ()) path

let stdlib_path = resolve "node_modules/bs-platform/lib/ocaml"

let config () =
  let () = open_out ("Makefile.config" |> concat stdlib_path) |> close_out in
  let () = print_endline "version: 4.06.0" in
  let () = print_endline ("standard_library_default: " ^ stdlib_path) in
  let () = print_endline ("standard_library: " ^ stdlib_path) in
  let () = print_endline "ccomp_type: echo 1" in
  let () = print_endline "c_compiler: echo 2" in
  let () = print_endline "ocamlc_cflags: -O2 -fno-strict-aliasing -fwrapv -fPIC" in
  let () = print_endline "ocamlc_cppflags: -D_FILE_OFFSET_BITS=64 -D_REENTRANT" in
  let () = print_endline "ocamlopt_cflags: -O2 -fno-strict-aliasing -fwrapv" in
  let () = print_endline "ocamlopt_cppflags: -D_FILE_OFFSET_BITS=64 -D_REENTRANT" in
  let () = print_endline "bytecomp_c_compiler: echo 3" in
  let () = print_endline "native_c_compiler: echo 4" in
  let () = print_endline "bytecomp_c_libraries: -lm -ldl  -lpthread " in
  let () = print_endline "native_c_libraries: -lm -ldl " in
  let () = print_endline "native_pack_linker: ld -r -o " in
  let () = print_endline "ranlib: ranlib" in
  let () = print_endline "architecture: js" in
  let () = print_endline "model: default" in
  let () = print_endline "int_size: 63" in
  let () = print_endline "word_size: 64" in
  let () = print_endline "system: linux" in
  let () = print_endline "asm: as" in
  let () = print_endline "asm_cfi_supported: false" in
  let () = print_endline "with_frame_pointers: false" in
  let () = print_endline "ext_exe: " in
  let () = print_endline "ext_obj: .o" in
  let () = print_endline "ext_asm: .s" in
  let () = print_endline "ext_lib: .a" in
  let () = print_endline "ext_dll: .so" in
  let () = print_endline "os_type: Unix" in
  let () = print_endline "default_executable_name: a.out" in
  let () = print_endline "systhread_supported: true" in
  let () = print_endline "host: x86_64-pc-linux-gnu" in
  let () = print_endline "target: x86_64-pc-linux-gnu" in
  let () = print_endline "flambda: false" in
  let () = print_endline "spacetime: false" in
  let () = print_endline "safe_string: true" in
  let () = print_endline "default_safe_string: true" in
  let () = print_endline "flat_float_array: true" in
  let () = print_endline "function_sections: true" in
  let () = print_endline "afl_instrument: false" in
  let () = print_endline "windows_unicode: false" in
  let () = print_endline "supports_shared_libraries: true" in
  let () = print_endline "exec_magic_number: Caml1999X027" in
  let () = print_endline "cmi_magic_number: Caml1999I027" in
  let () = print_endline "cmo_magic_number: Caml1999O027" in
  let () = print_endline "cma_magic_number: Caml1999A027" in
  let () = print_endline "cmx_magic_number: Caml1999Y027" in
  let () = print_endline "cmxa_magic_number: Caml1999Z027" in
  let () = print_endline "ast_impl_magic_number: Caml1999M027" in
  let () = print_endline "ast_intf_magic_number: Caml1999N027" in
  let () = print_endline "cmxs_magic_number: Caml1999D027" in
  let () = print_endline "cmt_magic_number: Caml1999T027" in
  ()

let correct_args args =
    let args =
        args
  |> Array.to_list
  |> List.filter (function e -> e <> "-opaque" && e <> "-custom" && e <> "-impl")
  |> List.map (function
      "-g" -> "-bs-g"
    | e when Filename.extension e = ".cmo" -> Filename.remove_extension e ^ ".cmj"
(*    | "-o" -> "-bs-package-output"
    | "test/.a.eobjs/byte/dune__exe__A.cmo" ->
            let () = Unix.mkdir "test" 0o777 in
            let () = Unix.mkdir "test/.a.eobjs" 0o777 in
            let () = Unix.mkdir "test/.a.eobjs/byte" 0o777 in
            "commonjs:test/.a.eobjs/byte"*)
    | e -> e)
    in
    let output_file_name, args =
        let rec loop = function
            [] -> failwith "-o is absent"
          | "-o" :: name :: l -> name, "-o" :: name :: l
          | e :: l ->
            let output_file_name, args = loop l in
            output_file_name, e :: args
        in loop args
    in
  output_file_name, args |> Array.of_list

