use build.nu
use dump.nu
use env.nu
use fs.nu

# Output information about the current image including name and version
export def main [] {
    # get build values - the second row (index 1) contains the distro version
    # the last row contains the most recent item in the build log
    let build = build | transpose name version
    let distro = $build | select 1 | first
    let last = $build | last

    # read image values
    cd (env ETC)
    let image = fs read IMAGE
    let version = fs read VERSION

    # output a border above and below the image information
    let border = {|| let s = "="; 0..116 | reduce -f "" {|x, acc| $acc + $s } | $"(char newline)#($in)#(char newline)" | print }

    # output image info
    do $border
    $"bfren | ($image)" | ^figlet -w 120
    char newline | print
    $"bfren/($image):($version) [($distro.name | str downcase):($distro.version)] [($last.name | str downcase):($last.version)]" | print
    $"Built on (ls IMAGE | first | get modified)" | print
    char newline | print
    $"https://github.com/bfren/docker-($image)" | print
    do $border
}
