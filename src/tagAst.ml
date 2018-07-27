(* AST definition of LinGL *)

open CoreAst

(* tag types *)
type tag_typ = 
    | TopTyp of int
    | BotTyp of int
    | VarTyp of id

(* types *)
type typ =
    | UnitTyp
    | BoolTyp
    | IntTyp
    | FloatTyp
    | TagTyp of tag_typ
    | TransTyp of tag_typ * tag_typ
    | SamplerTyp of int (* i.e. sampler2D *)
    | VoidTyp

(* expressions *)
type exp =
    | Val of value
    | Var of id
    | Unop of unop * exp
    | Binop of binop * exp * exp
    | VecTrans of int * tag_typ (* vec3(<vec4>), vec4(<vec3>) *)
    | FnInv of id * args (* function invocation *)

(* arguments *)
and args = exp list

(* function declaration *)
type params = (id * typ) list
type ret_type = typ
(* we do not have higher order functions *)
type fn_type = params * ret_type
type fn_decl = id * fn_type

(* commands *)
type comm = 
    Skip
    | Print of exp
    | Decl of typ * id * exp
    | Assign of id * exp
    | If of exp * comm list * comm list

type fn = fn_decl * comm list

(* tag declaration statements *)
type tag_decl = string * typ

(* program *)
type prog =
    | Prog of tag_decl list * fn list

