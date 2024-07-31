use dump.nu
use handle.nu
use write.nu

# Perform a package action, capturing result and outputting any errors
def action [
    name: string
    description: string
    cmd: string
    args: list<string>
] {
    # add pkg to the script name
    let script = $"pkg/($name)"

    # use shell to run apk
    let joined = $args | str join " "
    write debug $"($description): ($joined)." $script
    let on_failure = {|code, err| write error --code $code $"Error ($description | str downcase) packages: ($joined)." $script }
    { ^apk $cmd --no-cache ...$args } | handle -d $"($description) packages" -f $on_failure $script
}

# Use apk to install a list of packages
export def install [
    args: list<string>  # List of packages to add / arguments
] {
    action "install" "Installing" "add" $args
}

# Use apk to remove a list of packages
export def remove [
    args: list<string>  # List of packages to delete / arguments
] {
    action "remove" "Removing" "del" $args
}

# Use apk to upgrade a list of packages
export def upgrade [
    args: list<string> = []  # List of packages to upgrade / arguments
] {
    action "upgrade" "Upgrading" "upgrade" $args
}
