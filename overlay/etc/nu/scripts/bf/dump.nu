# Dump input value if debug is enabled, then return original value
export def main [
    --text (-t): string # Optional string to print before input
] {
    # capture input variable so we can reuse it
    let input = $in

    # check BF_DEBUG directly so dump can be used everywhere (including env.nu module)
    if ($env | get --ignore-errors BF_DEBUG | into string) == "1" {
        # output optional text heading
        if $text != null { $"(char newline)#== ($text) ==#" | print }

        # output as an expanded table
        $input | table --expand | print
    }

    # return the original input unchanged
    $input
}
