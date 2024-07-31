use fs.nu
use write.nu

# Execute tests with debug switch enabled
# Inspired by https://github.com/nushell/nupm/blob/main/nupm/test.nu to work in this ecosystem
export def main [] { with-env { BF_DEBUG: 1, PATH: "/usr/bin" } { discover | execute } }

# Discover tests to execute
def discover [] {
    # ensure tests directory contains a mod.nu file
    if ("/etc/nu/scripts/tests/mod.nu" | fs is_not_file) {
        write error "The tests directory does not exist, or does not contain a mod.nu file."
    }

    # get list of tests
    let tests = ^nu ...[
        --commands
        'use tests

        scope commands
        | where ($it.name | str starts-with tests)
        | get name
        | str replace "tests" ""
        | str trim
        | to nuon
        '
    ] | from nuon

    # if no tests are found, exit
    if ($tests | length) == 0 {
        write "No tests found."
        exit
    }

    # execute each test
    write $"Found ($tests | length) tests."

    # return
    $tests
}

# Execute each discovered test
def execute [] {
    # execute each test
    let results = $in | sort | each {|x|
        # capture result
        let result = do { ^nu -c $"use tests * ; ($x)" } | complete

        # output result on success
        if $result.exit_code == 0 { $"(ansi gb)OK(ansi reset) ($x)" | print }

        # return result
        {
            test: $x
            stdout: $result.stdout
            stderr: $result.stderr
            exit_code: $result.exit_code
        }
    }

    # if no failures, print success message
    let failures = $results | where exit_code != 0
    if ($failures | length) == 0 {
        write ok $"Executed all ($results | length) tests successfully."
        return
    }

    # output each failure and error message
    $failures | each {|x|
        $"(char newline)(ansi rb)FAILED(ansi reset) ($x.test)(char newline)($x.stderr)" | print
    }
    error make --unspanned {msg: $"($failures | length) of ($results | length) tests failed."}
}
