+++
date = 2018-03-20
tags = ["Code Dump", "OCaml"]
title = "An open value interpreter"
+++

```ocaml
type 'value expr =
| App of 'value expr * 'value expr
| Eq of 'value expr * 'value expr
| Id of string
| If of 'value expr * 'value expr * 'value expr
| Lambda of string * 'value expr
| Let of string * 'value expr * 'value expr
| LetRec of string * 'value expr * 'value expr
| Val of 'value

exception NoSuchVar of string
exception TypeError of string

let rec lookup name = function
| [] -> raise (NoSuchVar name)
| (n, v) :: _ when name = n -> v
| _ :: t -> lookup name t;;

let rec eval env = function
| App(f, x) ->
        let f' = eval env f
        and x' = eval env x
        in (match f' with
        | `BuiltinFunc(f) -> f x'
        | `Closure(var, body, env') -> eval ((var, x')::env') body
        | _ -> failwith "Invalid App LHS")
| Eq(l, r) ->
        let l' = eval env l
        and r' = eval env r
        in `Bool(l' = r')
| Id(x) -> lookup x env
| If(c, t, e) ->
        (match eval env c with
        | `Bool(true) -> eval env t
        | `Bool(false) -> eval env e
        | _ -> raise (TypeError "bool"))
| Lambda(arg, body) -> `Closure(arg, body, env)
| Let(bv, be, expr) ->
        let v = eval env be
        in eval ((bv, v)::env) expr
| LetRec(bv, Lambda(arg, body), expr) ->
        let rec env' = (bv, `Closure(arg, body, env'))::env
        in eval env' expr
| LetRec(_, _, _) -> failwith "Invalid LetRec"
| Val(v) -> v;;

let evaluate = eval [];;

(** An expression that doesn't actually use any values has a completely
 *  unconstrained value type parameter; i.e. it's of type 'a expr. *)
let omega = Lambda("x", App(Id("x"), Id("x")))

(** The type inferred here without the annotation on op is pretty loose, since
 *  there's nothing actually saying what type `Int corresponds to. Furthermore,
 *  there's nothing forcing l, r, and the return type to all be the same
 *  either. *)
let arith_op (op: int -> int -> int) l r =
    let f = `BuiltinFunc(function
    | `Int l -> `BuiltinFunc(function
        | `Int r -> `Int(op l r)
        | _ -> raise (TypeError "int"))
    | _ -> raise (TypeError "int"))
    in App(App(Val(f), l), r);;

(* Just some helpers. *)
let add (l, r) = arith_op ( + ) l r
let mul (l, r) = arith_op ( * ) l r

(** An expression using ints. The type evaluated to here still is either a
 *  built-in function or an int -- the types forced to exist by eval don't need
 *  to exist, since eval isn't actually involved here. *)
let int_stuff = mul(
    add(Val(`Int(1)), Val(`Int(2))),
    add(Val(`Int(3)), Val(`Int(4))));;

(* We can use strings too, without having declared them above. *)

(** Concatenates two strings. *)
let strcat = Val(`BuiltinFunc(function
| `String(s1) -> `BuiltinFunc(function
    | `String(s2) -> `String(s1 ^ s2)
    | _ -> raise (TypeError "String"))
| _ -> raise (TypeError "String")))

(** Gets the length of a string. You can see that the type inference figures
 *  out that this is String -> Int, and so will force both to be valid values
 *  for the exprs this is embedded in. *)
let strlen = Val(`BuiltinFunc(function
| `String(s) -> `Int(String.length s)
| _ -> raise (TypeError "String")))

(** The code used below; the type here is again somewhat unhelpful, other than
 *  exposing the structure of the code itself. *)
let hello_world_len =
    Let("s1", Val(`String("Hello")),
    Let("s2", Val(`String("World")),
    App(strlen, App(App(strcat, Id("s1")), Id("s2")))))
```
