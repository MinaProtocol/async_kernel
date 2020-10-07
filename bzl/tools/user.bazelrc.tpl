build --symlink_prefix=.bazel/ # use hidden dirs instead of top-level symlinks
# do not create `bazel-out` symlink if a different name is given to `--symlink_prefix`.
build --experimental_no_product_name_out_symlink

build --color=yes
build --subcommands=pretty_print
build --verbose_failures
build --sandbox_debug

# build --show_timestamps
# build --keep_going
# build --jobs 600
# query --keep_going

## when running tests this will provide hints for 'size' or 'timeout' attribs: :
# test --test_verbose_timeout_warnings

## You can override the WORKSPACE definition of a repo.

# 'common' - applies to both build and query commands
# common --override_repository=obazl_rules_ocaml=/path/to/obazl
