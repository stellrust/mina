[%%import "/src/config.mlh"]

open Core_kernel
open Snark_params.Tick

module type S = sig
  exception Too_long_user_memo_input

  exception Too_long_digestible_string

  type t [@@deriving sexp, equal, compare, hash, yojson]

  module Stable : sig
    module V1 : sig
      type nonrec t = t
      [@@deriving bin_io, sexp, equal, compare, hash, yojson, version]

      module With_all_version_tags : Bin_prot.Binable.S with type t = t
    end

    module Latest = V1
  end

  module Checked : sig
    type unchecked = t

    type t = private Boolean.var array

    val constant : unchecked -> t
  end

  (** typ representation *)
  val typ : (Checked.t, t) Typ.t

  val dummy : t

  val empty : t

  val to_base58_check : t -> string

  val of_base58_check : string -> t Or_error.t

  val of_base58_check_exn : string -> t

  (** for a memo of bytes, return a plaintext string
      for a memo of a digest, return a hex-encoded string, prefixed by '0x'
  *)
  val to_string_hum : t -> string

  (** is the memo a digest *)
  val is_digest : t -> bool

  (** is the memo well-formed *)
  val is_valid : t -> bool

  (** bound on length of strings to digest *)
  val max_digestible_string_length : int

  (** bound on length of strings or bytes in memo *)
  val max_input_length : int

  (** create a memo by digesting a string; raises [Too_long_digestible_string] if
      length exceeds [max_digestible_string_length]
  *)
  val create_by_digesting_string_exn : string -> t

  (** create a memo by digesting a string; returns error if
      length exceeds [max_digestible_string_length]
  *)
  val create_by_digesting_string : string -> t Or_error.t

  (** create a memo from bytes of length up to max_input_length;
      raise [Too_long_user_memo_input] if length is greater
  *)
  val create_from_bytes_exn : bytes -> t

  (** create a memo from bytes of length up to max_input_length; returns
      error is length is greater
  *)
  val create_from_bytes : bytes -> t Or_error.t

  (** create a memo from a string of length up to max_input_length;
      raise [Too_long_user_memo_input] if length is greater
  *)
  val create_from_string_exn : string -> t

  (** create a memo from a string of length up to max_input_length;
      returns error if length is greater
  *)
  val create_from_string : string -> t Or_error.t

  (** convert a memo to a list of bools
  *)
  val to_bits : t -> bool list

  (** Quickcheck generator for memos. *)
  val gen : t Quickcheck.Generator.t

  (** Compute a standalone hash of the current memo. *)
  val hash : t -> Field.t

  (* This type definition was generated by hovering over `deriver` in signed_command_memo.ml and copying the type *)
  val deriver :
       (< contramap : (t -> Yojson.Safe.t) ref
        ; graphql_arg :
            (unit -> Yojson.Safe.t Fields_derivers_graphql.Schema.Arg.arg_typ)
            ref
        ; graphql_fields :
            Yojson.Safe.t Fields_derivers_zkapps.Graphql.Fields.Input.T.t ref
        ; graphql_query : string option ref
        ; graphql_query_accumulator : (string * string option) list ref
        ; map : (Yojson.Safe.t -> t) ref
        ; nullable_graphql_arg :
            (   unit
             -> Yojson.Safe.t option Fields_derivers_graphql.Schema.Arg.arg_typ
            )
            ref
        ; nullable_graphql_fields :
            Yojson.Safe.t option Fields_derivers_zkapps.Graphql.Fields.Input.T.t
            ref
        ; of_json : (Yojson.Safe.t -> Yojson.Safe.t) ref
        ; to_json : (Yojson.Safe.t -> Yojson.Safe.t) ref
        ; js_layout : Yojson.Safe.t ref
        ; .. >
        as
        'a )
       Fields_derivers_zkapps.Unified_input.t
       Fields_derivers_zkapps.Unified_input.t
       Fields_derivers_zkapps.Unified_input.t
    -> 'a Fields_derivers_zkapps.Unified_input.t

  type raw =
    | Digest of string  (** The digest of the string, encoded by base58-check *)
    | Bytes of string  (** A string containing the raw bytes in the memo. *)

  (** Convert into a raw representation.

      Raises if the tag or length are invalid.
  *)
  val to_raw_exn : t -> raw

  (** Convert back into the raw input bytes.

      Raises if the tag or length are invalid, or if the memo was a digest.
      Equivalent to [to_raw_exn] and then a match on [Bytes].
  *)
  val to_raw_bytes_exn : t -> string

  (** Convert from a raw representation.

      Raises if the digest is not a valid base58-check string, or if the bytes
      string is too long.
  *)
  val of_raw_exn : raw -> t
end
