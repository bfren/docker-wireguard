use std/assert
use bf


#======================================================================================================================
# installation
#======================================================================================================================

export def install__wireguard_tools_match_build [] {
    let build = with-env {BF_ETC: "/etc/bf"} { bf build | get WireGuard }
    let installed = ^wg --version | parse --regex 'v(?<v>\d+\.\d+\.\d+)' | get v.0

    assert ($build | str starts-with $installed) $"wireguard-tools ($installed) should match the build ($build)"
}

export def install__tools_are_installed [] {
    for x in [wg wg-quick iptables qrencode] {
        assert (which $x | is-not-empty) $"($x) should be installed"
    }
}


#======================================================================================================================
# scripts
#======================================================================================================================

export def scripts__parse [] {
    let paths = [
        "/usr/bin/bf/wg-clients"
        "/usr/bin/bf/wg-conf"
        "/usr/bin/bf/wg-qr"
        "/usr/bin/bf/wg-show"
        "/etc/s6-overlay/s6-rc.d/wireguard/run"
        "/etc/s6-overlay/s6-rc.d/wireguard/finish"
        "/etc/bf/init.d/11-keys.nu"
        "/etc/bf/init.d/12-peers.nu"
        "/etc/bf/init.d/13-conf.nu"
    ]
    for path in $paths {
        let result = ^$nu.current-exe --no-config-file --commands $"nu-check ($path)" | complete
        assert equal "true" ($result.stdout | str trim) $"($path) does not parse: ($result.stderr)"
    }
}
