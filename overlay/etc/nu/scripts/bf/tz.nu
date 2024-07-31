use fs.nu
use del.nu
use dump.nu
use pkg.nu
use write.nu

# path to current timezone info
const localtime = "/etc/localtime"

# path to file containing name of current timezone
const timezone = "/etc/timezone"

# path to installed timezone definition files
const zoneinfo = "/usr/share/zoneinfo"

# Set the container's timezone
export def main [
    tz: string  # The name of the timezone to use
] {
    # if current timezone is already $tz, do nothing
    let current = fs read --quiet $timezone
    if $current == $tz {
        write $"Timezone is already ($tz)." tz
        return
    }

    # get path to timezone definiton
    let zone = $"($zoneinfo)/($tz)"

    # install timezone package
    write debug "Installing tzdata packages." tz
    pkg install [--virtual .tz tzdata]

    # check the specified timezone exists
    if ($zone | fs is_not_file) {
        clean
        write error $"($tz) is not a recognise timezone." tz
    }

    # copy timezone info and write to file
    write $"Setting timezone to ($tz)." tz
    cp $zone $localtime
    $tz | save --force $timezone
    clean

    # return nothing
    return
}

# Remove tzdata packages and info
def clean [] {
    write debug "Removing tzdata packages." tz/clean
    pkg remove [.tz]
    del force $"($zoneinfo)/*"
}

# Return the name of the current timezone
export def current [] { fs read $timezone }
