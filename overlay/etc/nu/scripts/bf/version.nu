use dump.nu

# Returns true if version is at least equal to minimum
export def is_at_least [
    version: string # The version to check
    minimum: string # The minimum version required
] {
    # use natural sort to ensure (e.g.) 1.2.10 comes below 1.2.5
    let lowest = [$version $minimum] | sort --natural | first
    $lowest == $minimum
}

# Bump the patch number of the specified version (e.g. 1.2.10 -> 1.2.11)
export def bump [
    version: string # The version to bump
] {
    $version | split row "." | $"($in.0).($in.1).($in.2 | into int | $in + 1)"
}
