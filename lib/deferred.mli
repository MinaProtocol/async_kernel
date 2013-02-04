open Core.Std
open Import
open Deferred_intf

(** A deferred is a value that will become determined asynchronously.  A deferred can be
    "undetermined" or "determined".  A deferred that is undetermined may at some point
    become determined with value v, and will henceforth always be determined with value
    v. *)
type +'a t = 'a Ivar.Deferred.t with sexp_of

(** [sexp_of_t t f] returns a sexp of the deferred's value, if it is determined, or an
    informative string otherwise.

    This is just for display purposes.  There is no [t_of_sexp]. *)

(** [create f] calls [f i], where [i] is empty ivar.  [create] returns a deferred that
    becomes determined when [f] fills [i]. *)
val create : ('a Ivar.t -> unit) -> 'a t

(** [upon t f] will run [f v] at some point after [t] becomes determined with value
    [v]. *)
val upon : 'a t -> ('a -> unit) -> unit

(** [peek t] returns [Some v] iff [t] is determined with value [t]. *)
val peek : 'a t -> 'a option

(** [is_determined t] returns [true] iff [t] is determined. *)
val is_determined : 'a t -> bool

(** Deferreds form a monad.

    [t >>= f] returns a deferred t' that waits until t is determined to have
    value v, at which point it waits for f v to become determined with value
    v', to which t' will become determined.

    [return v] returns a deferred that is immediately determined with value
    v.

    Note that

    {[
      upon t f
    ]}

    is more efficient than

    {[
      ignore (t >>= (fun a -> f a; Deferred.unit))
    ]}

    because [upon], unlike [>>=] does not create a deferred to hold the result.

    For example, one can write a loop that has good constant factors with:

    {[
      let rec loop () =
        upon t (fun a -> ... loop () ... )
    ]}

    The same loop written with [>>=] would allocate deferreds that would be immediately
    garbage collected.  (In the past, this loop would have also used linear space in
    recursion depth!)

    In general, for deferreds that are allocated by [>>=] to be garbage collected quickly,
    it is sufficient that the allocating bind be executed in tail-call position of the
    right-hand side of an outer bind. *)
include Monad with type 'a t := 'a t

module Infix : sig
  include Monad.Infix with type 'a t := 'a t
  val (>>>) : 'a t -> ('a -> unit) -> unit
end

(** [unit] is a deferred that is always determined with value [()] *)
val unit : unit t

(** [never ()] returns a deferred that never becomes determined *)
val never : unit -> _ t

(** [both t1 t2] becomes determined after both [t1] and [t2] become determined. *)
val both : 'a t -> 'b t -> ('a * 'b) t

(** [all ts] returns a deferred that becomes determined when every t in ts
    is determined.  The output is in the same order as the input. *)
val all : 'a t list -> 'a list t

(** Like [all], but ignores results of the component deferreds *)
val all_unit : unit t list -> unit t

(** [any ts] returns a deferred that is fulfilled when any of the underlying deferreds is
    fulfilled *)
val any : 'a t list -> 'a t

(** [any_unit ts] like [any] but ignores results of the component deferreds *)
val any_unit : 'a t list -> unit t

module type Monad_sequence = Monad_sequence with type 'a monad := 'a t

module Array : Monad_sequence with type 'a t = 'a array
module List  : Monad_sequence with type 'a t = 'a list
module Queue : Monad_sequence with type 'a t = 'a Queue.t

module Map : Deferred_map

module Result : Monad.S2 with type ('a, 'b) t = ('a, 'b) Result.t t

module Option : Monad.S  with type 'a t = 'a option t

(** [don't_wait_for t] ignores t completely.  It is like [Fn.ignore], but is more
    constrained because it requires a [unit Deferred.t].

    Rather than [ignore (t : _ t)], do [don't_wait_for (Deferred.ignore t)].

    We chose to give [don't_wait_for] type [unit t] rather than [_ t] to catch errors
    where a value is accidentally ignored. *)
val don't_wait_for : unit t -> unit

(** [choice] is used to produce an argument to [enabled] or [choose].  See below. *)
type 'a choice

val choice : 'a t -> ('a -> 'b) -> 'b choice

(** [enabled [choice t1 f1; ... choice tn fn;]] returns a deferred [d] that becomes
    determined when any of the [ti] become determined.  The value of [d] is a function [f]
    that when called, for each [ti] that is enabled, applies [fi] to [ti], and returns a
    list of the results.  It is guaranteed that the list is in the same order as the
    choices supplied to [enabled], but of course it may be shorter than the input list if
    not all [ti] are determined. *)
val enabled : 'b choice list -> (unit -> 'b list) t

(** [choose choices] is [enabled choices >>| (fun f -> List.hd_exn (f ()))].
    That is:

    {[
      choose [choice t1 f1; ...; choice tn fn]
    ]}

    returns a deferred [t] that becomes determined with value [fi ai] after some
    [ti] becomes determined with value [ai].  There is no guarantee that the [ti]
    that becomes determined earliest in time will be the one whose value
    determines the [choose].  Nor is it guaranteed that the value in [t] is the
    first value (in place order) from [choices] that is determined at the time [t]
    is examined.

    For example, if you write:

    {[
      choose [choice t1 (fun () -> `X1);
              choice t2 (fun () -> `X2);
             ]
      >>> function
      | `X1 -> e1
      | `X2 -> e2
    ]}

    It may be the case that both [d1] and [d2] become determined, yet the code
    [e2] actually runs.
*)
val choose : 'b choice list -> 'b t

(** [repeat_until_finished initial_state f] repeatedly runs [f] until [f] returns
    [`Finished].  The first call to [f] happens immediately when [repeat_until_finished]
    is called. *)
val repeat_until_finished
  :  'state
  ->  ('state -> [ `Repeat of 'state
                 | `Finished of 'result
                 ] t)
  -> 'result t

(** [forever initial_state f] repeatedly runs [f], supplying the state returned to the
    next call to [f]. *)
val forever
  :  'state
  -> ('state -> 'state t)
  -> unit

(** Set [debug_space_leaks] to [Some n] to trigger assertion failures when single deferred
    has more than [n] handlers waiting for it to be filled.  Note that if [n] is
    less than 2, we may not trigger all assertion failures. *)
val debug_space_leaks : int option ref

(** The [Raw] interface exposed here is for async's internal use only.  It must be
    exported here because we want the [Deferred.t] type to be fully abstract, so that they
    shows up nicely in type errors, yet other async code defined later needs to deal with
    the raw type. *)
include Raw
  with type execution_context := Execution_context.t
  with type ('a, 'b) raw := ('a, 'b) Raw_deferred.t
  with type 'a t := 'a t
