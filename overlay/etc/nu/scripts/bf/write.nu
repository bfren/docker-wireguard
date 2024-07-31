use dump.nu

# ansi colours for display
const colour = "reset"
const colour_debug = "grey"
const colour_ok = "green"
const colour_notok = "red_bold"

# Write text in standard colour with the current date / time
export def main [
    text: string    # The text to write
    script?: string # The name of the calling script or executable
] {
    fmt $text $colour $script | print
}

# Write text in grey with the current date / time, if BF_DEBUG is enabled
export def debug [
    text: string    # The text to write
    script?: string # The name of the calling script or executable
] {
    if ($env | get --ignore-errors BF_DEBUG | into string) == "1" {
        fmt $text $colour_debug $script | $"(ansi $colour_debug)($in)(ansi reset)" | print
    }
}

# Write error text in red with the current date / time, and exit using code
export def error [
    error: string           # The error text to write
    script?: string         # The name of the calling script or executable
    --code (-c): int = 1    # The error code to emit after the message
] {
    fmt $error $colour_notok $script | print --stderr
    exit $code
}

# Write text in red with the current date / time
export def notok [
    text: string    # The text to write
    script?: string # The name of the calling script or executable
] {
    fmt $text $colour_notok $script | print
}

# Write text in green with the current date / time
export def ok [
    text: string    # The text to write
    script?: string # The name of the calling script or executable
] {
    fmt $text $colour_ok $script | print
}

# Format text, optionally in a specified colour, with the current date / time and script name
def fmt [
    text: string    # The text to write
    colour: string  # ANSI colour code to use for the text
    script?: string # The name of the calling script or executable
] {
    # get the name of the base executable
    let bf_x = $env | get --ignore-errors BF_X | $"($in)" | str trim

    # use BF_X or the calling script as the prefix
    let prefix = if $script != null {
        if $bf_x != "" {
            $"($bf_x): "
        } else {
            $"($script): "
        }
    } else if $bf_x != "" {
        $"($bf_x): "
    }

    # if script and BF_X are both set, BF_X is the prefix, so use script as the suffix
    let suffix = if $script != null and $bf_x != "" { $" \(($script)\)" }

    # format date and write text
    let date = date now | format date "%Y-%m-%d %H:%M:%S"
    $"[bf] ($date) | (ansi $colour)($prefix)($text)($suffix)(ansi reset)"
}
