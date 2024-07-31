use build.nu
use ch.nu
use clean.nu
use del.nu
use dump.nu
use env.nu
use fs.nu
use image.nu
use test.nu
use write.nu
use x.nu

# Run standard installation for the container:
#   - show build information
#   - show bfren environment
#   - run container's installation script
#   - set permissions
#   - store image info
#   - run cleanup
#   - output image info
export def main [] {
    # output build info
    write "Build information." install
    build show

    # output BF config
    write "bfren platform environment variables." install
    env show

    # set permissions
    write "Setting permissions." install
    env apply_perms
    let root = "root:root"
    ["/etc/nu" $root 0666 0777] | ch apply
    ["/init" $root 0500 ] | ch apply
    ["/tmp" $root 1777 1777] | ch apply
    ["/usr/bin/bf" $root 0555] | ch apply

    # run install script in /tmp
    const install = /tmp/install
    if ($install | fs is_not_file) {
        write debug $"($install) does not exist." install
    } else {
        write $"Executing ($install)." install
        x $install
    }

    # store versions
    write "Storing image information." install
    cd (env ETC)
    env IMAGE | str replace "docker-" "" | save --force IMAGE
    env VERSION | save --force VERSION

    # clean installation files / caches etc
    write "Running cleanup."
    clean

    # all finished
    write ok "Installation complete." install
    image
}
