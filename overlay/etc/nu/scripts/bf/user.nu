use dump.nu
use handle.nu
use write.nu

# Add a non-login user and group of the specified name, optionally specifying UID and GID
export def add [
    name: string            # The name of the user and group to add
    --uid (-u): int = 1000  # The user's UID
    --gid (-g): int         # The group's GID (if not set, UID will be used)
] {
    # if user exists show an error
    if (exists $name) { write error $"User ($name) already exists." user/add }

    # if GID is set, use it, otherwise use UID
    let home = $"/home/($name)"
    let use_gid = if $gid != null { $gid } else { $uid }
    write $"Adding user ($name) with UID ($uid) and GID ($use_gid)." user/add

    # add group and user
    add_user_and_group $name $home $uid $use_gid

    # create links to Nushell files and directories
    create_nushell_links $name $home

    # return nothing
    return
}

# Add a new user and group with the same name
export def add_user_and_group [
    name: string    # The name of the user and group to add
    home: string    # The user's home directory
    uid: int        # The user's UID
    gid: int        # The group's GID
] {
    # explicitly use busybox executables to support both Alpine and Debian
    {
        ^busybox addgroup --gid $gid $name
        ^busybox adduser --uid $uid --home $home --disabled-password --ingroup $name $name
    } | handle user/add
}

# Create links between shared Nushell config and a user's config
export def create_nushell_links [
    name: string    # The user name
    home: string    # The user's home directory
] {
    # create paths to directories
    let shared_nu = "/etc/nu"
    let user_home = if $home != null { $home } else { $"/home/($name)" }
    let user_nu = $"($user_home)/.config/nushell"

    # ensure user's Nushell config directory exists and they own it
    mkdir $user_nu
    { ^chown $"($name):($name)" $user_nu } | handle user/create_nushell_links

    # link the shared Nushell files and directories to the user's config directory
    { ^ln -sf $"($shared_nu)/config.nu" $"($user_nu)/config.nu" }  | handle user/create_nushell_links
    { ^ln -sf $"($shared_nu)/env.nu" $"($user_nu)/env.nu" } | handle user/create_nushell_links
    { ^ln -sf $"($shared_nu)/scripts" $"($user_nu)/scripts" } | handle user/create_nushell_links
}

# Checks whether or not user $name exists in /etc/passwd
export def exists [
    name: string    # The user name
] {
    { ^getent passwd $name } | handle -c user/exists | $in == 0
}
