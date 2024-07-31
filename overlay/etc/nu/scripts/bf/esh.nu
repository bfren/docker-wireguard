use dump.nu
use env.nu
use fs.nu
use handle.nu
use write.nu

# Generate output using input as an esh template
export def main [
    input: string   # Input file
    output?: string # Output file - if omitted the output will be returned instead of saved
] {
    # debug message
    write debug $"Parsing esh template ($input)." esh

    # ensure template file exists
    if ($input | fs is_not_file) { write error $"Template ($input) does not exist." esh }

    # dump esh output and write error message
    let on_failure = {|c,e|
        $e | print --no-newline --stderr
        write error --code $c $"Error parsing template ($input)." esh
    }
    let on_success = {
        write debug $" .. output saved to ($output)." esh
    }

    # generate template
    #   and: return value if $output is not set
    #   or:  save to file if $output is set
    if $output == null {
        { ^esh $input } | handle -f $on_failure esh
    } else {
        { ^esh -o $output $input } | handle -f $on_failure  -s $on_success esh
    }
}

# It is common to generate a file using an esh template in the bf templates directory, so this makes that easier
# - it assumes a file with the same basename as $output plus '.esh' exists in the templates directory
# - and that the $output directory exists
export def template [
    output: string  # Absolute path to the output file
] {
    # get filenames and paths
    let filename = $output | path basename
    let output_dir = $output | path dirname
    let input = $"(env ETC_TEMPLATES)/($filename).esh"

    # ensure input file and output directory exist
    if ($input | fs is_not_file) { write error $"Template file ($input) does not exist." esh/template }
    if ($output_dir | fs is_not_dir) { write error $"Output directory ($output_dir) does not exist." esh/template }

    # output debug message and generate file
    write debug $" .. ($filename).esh"
    main $input $output
}
