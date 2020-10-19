ALWAYS_LINK = select({
    "//bzl/config:enable_always_link": ["-linkall"],
    "//conditions:default": [],
})

DEBUG = select({
    "//bzl/config:enable_debug": ["-g"],
    "//conditions:default": [],
})

THREADS = select({
    "//bzl/config:enable_threads": ["-thread"],
    "//conditions:default": [],
})

VERBOSE = select({
    "//bzl/config:enable_verbose": ["-verbose"],
    "//conditions:default": [],
})

GLOBAL_CLI_OPTS = THREADS + ALWAYS_LINK + VERBOSE + DEBUG

WARNINGS = ["-w", "@1..3@5..28@30..39@43@46..47@49..57@61..62-40"]
OPTS = ["-strict-formats", "-short-paths", "-keep-locs"] + GLOBAL_CLI_OPTS

ARCHIVE_OPTS    = WARNINGS + OPTS
EXECUTABLE_OPTS = WARNINGS + OPTS
INTERFACE_OPTS  = WARNINGS + OPTS
MODULE_OPTS     = WARNINGS + OPTS
NS_MODULE_OPTS  = WARNINGS + OPTS + [
    "-w", "-49",      # ignore Warning 49: no cmi file was found in path for module x
    "-no-alias-deps", # lazy linking
    "-opaque"         #  do not generate cross-module optimization information
]


