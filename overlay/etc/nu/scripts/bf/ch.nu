use dump.nu
use env.nu
use fs.nu
use write.nu

# Apply ownership or permissions values to files and directories matched by glob
export def main [
    ...paths: string            # The paths to which to apply ch operations
    --debug (-d)                # Override BF_DEBUG for this call
    --mode (-m): string         # Use chmod: Set permissions to this mode
    --owner (-o): string        # Use chown: Set ownership to this user & group
    --recurse (-r)              # Adds -R to chmod / chown to recurse (overrides type if that is set too)
    --type (-t): string         # Apply to directories (d), files (f) or symlinks (l)
] {
    # override debug
    if $debug { $env.BF_DEBUG = "1" }

    # if recurse is set, execute chmod/chown on each path with recursion
    if $recurse {
        $paths | each {|x|
            if $mode != null { apply_mod_recurse $x $mode }
            if $owner != null { apply_own_recurse $x $owner }
        }
        return
    }

    # if type is set, find all paths of type within each path and execute chmod/chown on them
    if $type != null {
        $paths | each {|x|
            if $mode != null { apply_mod_type $x $type $mode }
            if $owner != null { apply_own_type $x $type $owner }
        }
        return
    }

    # otherwise, execute chmod/chown on each path
    $paths | each {|x|
        if $mode != null { apply_mod $x $mode }
        if $owner != null { apply_own $x $owner }
    }

    return
}

# Apply permissions for a row container in a ch.d file:
#   1. file / directory path
#   2. owner (for chown)
#   3. optional: file mode (for chmod)
#   4. optional: directory mode (for chmod)
export def apply [] {
    # we need at least two values: glob and owner
    let row = $in
    if ($row | length) < 2 { return }

    # get values - path and owner are required, fmode and dmode are optional
    let path = $row | get 0
    let owner = $row | get 1
    let fmode = $row | get -i 2 | into string
    let dmode = $row | get -i 3 | into string

    # apply ownership changes
    apply_own_recurse $path $owner

    # apply mode changes
    if $fmode != null { apply_mod_type $path f $fmode }
    if $dmode != null { apply_mod_type $path d $dmode }
}

# Apply permissions using a ch.d file
export def apply_file [
    file: string    # Path to ch.d file - if the file does not exist, will look in ch.d directory instead
] {
    # if file is not a path that exists, prepend CH_D directory
    let path = if ($file | path exists) { $file } else { $"(env ETC_CH_D)/($file)" }

    # check file exists
    if ($path | fs is_not_file) {
        write notok $"($path) does not exist or is not a file." ch/apply_file
        return
    }

    # split by row and apply changes row by row
    write $"Applying ($path)." ch/apply_file
    open $path | from ssv --minimum-spaces 1 --noheaders | each {|x| $x | values | apply }

    # return nothing
    return
}

# Apply chmod to $path
def apply_mod [
    path: string    # File / directory path
    mode: string    # Permissions mode
] {
    write debug $" .. ($path): chmod ($mode)" ch/apply_mod
    if ($path | path exists) { ^chmod $mode $path }
}

# Apply chmod to $path recursively
def apply_mod_recurse [
    path: string    # File / directory path
    mode: string    # Permissions mode
] {
    write debug $" .. ($path): chmod -R ($mode)" ch/apply_mod_recurse
    if ($path | path exists) { ^chmod -R $mode $path }
}

# Apply chmod to all paths of $type under $base
def apply_mod_type [
    base: string    # Base directory
    type: string    # Path type (i.e. 'd', 'f', 'l')
    mode: string    # Permissions mode
] {
    write debug $" .. ($base): -($type) chmod ($mode)" ch/apply_mod_type
    if ($base | path exists) { ^busybox find $base -type $type -exec chmod $mode {} + }
}

# Apply chown to $path
def apply_own [
    path: string    # File / directory path
    owner: string   # Owner
] {
    write debug $" .. ($path): chown ($owner)" ch/apply_own
    if ($path | path exists) { ^chown $owner $path }
}

# Apply chown to $path recursively
def apply_own_recurse [
    path: string    # File / directory path
    owner: string   # Owner
] {
    write debug $" .. ($path): chown -R ($owner)" ch/apply_own_recurse
    if ($path | path exists) { ^chown -R $owner $path }
}

# Apply chown to all paths of $type under $base
def apply_own_type [
    base: string    # Base directory
    type: string    # Path type (i.e. 'd', 'f', 'l')
    owner: string   # Owner
] {
    write debug $" .. ($base): -($type) chown ($owner)" ch/apply_own_type
    if ($base | path exists) { ^busybox find $base -type $type -exec chown $owner {} + }
}
