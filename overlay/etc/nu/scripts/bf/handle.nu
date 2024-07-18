use dump.nu

# Handle an operation using `complete`, returning the operation stdout or printing stderr and exiting the program
#
# ```nu
# > { ^external } | bf handle
# ```
#   - `external` will be run using `do { } | complete`, capturing the exit code, stdout and stderr
#   - if the exit code is 0, stdout will be trimmed and returned
#   - if the exit code is not 0, stderr will be printed and the exit code used to exit the program
#
# ```nu
# > { ^external } | bf handle --code-only
# ```
#   - `external` will be run using `do { } | complete`, capturing the exit code, stdout and stderr
#   - the exit code will be returned
#   - **this option overrides all others**
#
# ```nu
# > { ^external } | bf handle --ignore-errors
# ```
#   - `external` will be run using `do { } | complete`, capturing the exit code, stdout and stderr
#   - whatever the exit code is, stdout will be trimmed and returned
#   - **this option overrides `--dump-result` and `--on-failure`**
#
# ```nu
# > { ^external } | bf handle --dump-result "Some Operation"
# ```
#   - `external` will be run using `do { } | complete`, capturing the exit code, stdout and stderr
#   - if the exit code is not 0, and BF_DEBUG is 1, the entire $result object will be dumped with 'Some Operation' used as a heading
#   - stderr will be printed and the exit code used to exit the program
#
# ```nu
# > { ^external } | bf handle --on-failure {|code, err| $"($err): ($code)" | print }
# ```
#   - `external` will be run using `do { } | complete`, capturing the exit code, stdout and stderr
#   - if the exit code is 0, stdout will be trimmed and returned
#   - if the exit code is not 0, $on_failure will be run - in this case the stderr and exit code will be printed
#
# ```nu
# > { ^external } | bf handle --on-success {|out| $out | print }
# ```
#   - `external` will be run using `do { } | complete`, capturing the exit code, stdout and stderr
#   - if the exit code is 0, $on_success will be run - in this case stdout will be printed
#   - if the exit code is not 0, stderr will be printed and the exit code used to exit the program
export def main [
    script?: string             # The name of the calling script or executable
    --code-only (-c)            # If set, only the exit code will be returned - overrides all other options
    --debug (-D)                # If set, the result object will be dumped immediately before any processing
    --dump-result (-d): string  # On error, dump the full $result object with this text
    --ignore-errors (-i)        # If set, any errors will be ignored and $result.stdout will be returned whatever it is
    --on-failure (-f): closure  # On failure, optionally run this closure with $code and $stderr as inputs
    --on-success (-s): closure  # On success, optionally run this closure with $stdout as input
]: closure -> any {
    # capture input so it can be reused
    let result = do $in | complete

    # if debugging is enabled, dump the $result object (it won't show unless BF_DEBUG is 1)
    if $debug { $result | dump }

    # return exit code
    if $code_only { return $result.exit_code }

    # on success, run closure (if it has been set) and return
    if $result.exit_code == 0 {
        if $on_success != null { do $on_success $result.stdout } else { $result.stdout | str trim } | return $in
    }

    # if ignoring errors, return the $result.stdout string
    if $ignore_errors { $result.stdout | str trim | return $in }

    # if we get here, the operation failed
    # if $dump_result flag is set, dump the $result object (it won't show unless BF_DEBUG is 1)
    if ($dump_result | is-not-empty) { $result | dump -t $dump_result }

    # run $on_failure closure (if it has been set) and return
    if $on_failure != null { do $on_failure $result.exit_code $result.stderr | return $in }

    # use stderr and exit code to write the error
    # we use the executable so handle can be used everywhere without causing cyclical import errors
    ^bf-write-notok ($result.stderr | str trim) $"($script)"
    exit $result.exit_code
}
