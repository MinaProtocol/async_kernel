# Async_kernel

`Async_kernel` contains `Async`'s core data structures, like `Deferred`.
`Async_kernel` is portable, and so can be used in JavaScript using Async_js. In
principle it could also be used on Windows, but no scheduler has been written
for Async on Windows as of yet.

API documentation for the latest release can be found
[here][https://ocaml.janestreet.com/ocaml-core/latest/doc/async/index.html].

## Bazel build

* `$ bazel build src:async_kernel`
* `$ bazel build eager_deferred/src:eager_deferred`
* `$ bazel build limiter_async/src:limiter_async`
* `$ bazel build persistent_connection_kernel/src:persistent_connection_kernel`

Build all: `$ bazel build //...:*`

## Bazel import

To use in another workspace, copy the obazl repo rules from
WORKSPACE.bazel into the workspace's WORKSPACE.bazel file, and add:

```
git_repository(
    name = "async_kernel",
    remote = "https://github.com/obazl/async_kernel",
    branch = "bazel",
)

```

Then refer to build targets in the workspace, e.g. `@async_kernel//src:async_kernel`
