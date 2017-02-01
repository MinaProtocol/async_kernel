open! Core_kernel
open Async_quickcheck_intf

module Generator = Quickcheck.Generator
module Observer  = Quickcheck.Observer

include Quickcheck_async_configured

module Configure (Config : Quickcheck_config) : Quickcheck_async_configured
