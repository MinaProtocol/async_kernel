# Changes for MinaProtocol

`async_kernel` was forked from `janestreet/async_kernel`. The first changes
for MinaProtocol were made atop tag v0.12.0 in branch `tracing`.

For OCaml 4.11.2, the Jane Street code at v0.13.0 was merged into the fork.
Atop that, these changes were made:

 - in `Async_kernel_scheduler`, expose `t`, `long_cycles_with_context`, and
    `long_jobs_with_context`
