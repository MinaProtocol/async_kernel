PACKAGES = {
    "core_kernel": ["v0.12.3", [
        "core_kernel.limiter",
        "core_kernel.moption",
        "core_kernel.thread_pool_cpu_affinity",
        "core_kernel.thread_safe_queue",
        "core_kernel.weak_hashtbl"
    ]],
    "async": ["v0.12.0"],
    "expect_test_helpers": ["v0.12.0"],
    "ppx_assert": ["v0.12.0", ["ppx_assert.runtime-lib"]],
    "ppx_bench": ["v0.12.0", ["ppx_bench.runtime-lib"]],
    "ppx_compare": ["v0.12.0", ["ppx_compare.runtime-lib"]],
    "ppx_enumerate": ["v0.12.0", ["ppx_enumerate.runtime-lib"]],
    "ppx_expect": ["v0.12.0", [
        "ppx_expect.collector",
        "ppx_expect.test"
    ]],
    "ppx_hash": ["v0.12.0", ["ppx_hash.runtime-lib"]],
    "ppx_inline_test": ["v0.12.0", ["ppx_inline_test.runtime-lib"]],
    "ppx_jane": ["v0.12.0"],
    "ppx_module_timer": ["v0.12.0", ["ppx_module_timer.runtime"]],
    "ppx_sexp_conv": ["v0.12.0", ["ppx_sexp_conv.runtime-lib"]],
    "ppxlib": ["0.8.1", ["ppxlib.metaquot"]],
}

opam = struct(
    version = "2.0",
    switches  = {
        "mina-0.1.0": struct(
            default  = True,
            compiler = "4.07.1",
            packages = PACKAGES
        ),
        "4.07.1": struct(
            compiler = "4.07.1",
            packages = PACKAGES
        )
    }
)
