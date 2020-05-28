let a, b = 3, 5

let a', b' = string_of_int a, string_of_int b


let () = E.log (a' ^ " + " ^ b' ^ E.(a + b))
let () = E.log (a' ^ " + " ^ b' ^ (string_of_int (C.add a b)))
