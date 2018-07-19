(* Tag AST pretty printer *)

open CoreAst
open CoreAstHelper
open TagAst

let string_of_vec (v: vec) : string = 
    "["^(String.concat ", " (List.map string_of_float v))^"]"

let string_of_mat (m: mat) : string = 
    "["^(String.concat ", " (List.map string_of_vec m))^"]"

let string_of_tag_typ (t: tagtyp) : string =
    match t with
    | TopTyp n -> "vec"^(string_of_int n)
    | BotTyp n -> "vec"^(string_of_int n)^"lit"
    | VarTyp s -> s

let rec string_of_typ (t: typ) : string = 
    match t with
    | UnitTyp -> "unit"
    | BoolTyp -> "bool"
    | IntTyp -> "int"
    | FloatTyp -> "float"
    | TagTyp s -> string_of_tag_typ s
    | TransTyp (s1, s2) -> (string_of_tag_typ s1) ^ "->" ^ (string_of_tag_typ s2)

let rec string_of_exp (e:exp) : string =
    let s_binop (op : string) (e1 : exp) (e2 : exp) =
        op ^ " " ^ (string_of_exp e1) ^ " " ^ (string_of_exp e2)
    in
    let inline_binop (op : string) (e1: exp) (e2: exp) =
        (string_of_exp e1) ^ " " ^ op ^ " " ^ (string_of_exp e2)
    in
    match e with
    | Val v -> string_of_value v
    | Var v -> v
    | Unop (op, x) -> (string_of_unop op) ^ " " ^ (string_of_exp x)
    | Binop (op, l, r) -> (match op with
        | Dot -> s_binop (string_of_binop op) l r
        | _ -> inline_binop (string_of_binop op) l r)
    | VecTrans (i, t) -> failwith "Unimplemented"

let rec string_of_comm (c: comm) : string =
    match c with
    | Skip -> "skip;"
    | Print e -> "print " ^ (string_of_exp e) ^ ";"
    | Decl (t, s, e) -> (string_of_typ t)^" " ^ s ^ " = " ^ (string_of_exp e) ^ ";"
    | If (b, c1, c2) -> "if (" ^ (string_of_exp b) ^ ") {\n" ^ (string_of_comm_list c1) ^
        "} else {\n" ^ (string_of_comm_list c2) ^ "}"
    | Assign (b, x) -> b^" = " ^ (string_of_exp x) ^ ";"

and 
string_of_comm_list (cl : comm list) : string = 
    match cl with
    | [] -> ""
    | h::t -> (string_of_comm h)^"\n"^(string_of_comm_list t)

let rec string_of_tags (t : tagdecl list) : string =
    match t with 
    | [] -> ""
    | (s, a)::t -> "tag " ^ s ^ " is "^(string_of_typ a) ^ ";\n" ^ (string_of_tags t)

let string_of_prog (e : prog) : string =
    match e with
    | Prog (t, c) -> (string_of_tags t) ^ (string_of_comm_list c) 
