use std/assert
use ../bf-wireguard/peers.nu
use ../bf-wireguard/clients.nu


#======================================================================================================================
# list
#======================================================================================================================

export def list__splits_names_on_spaces [] {
    let result = with-env {BF_WIREGUARD_PEERS: "foo-personal   bar-work fred    jones"} { peers list }

    assert equal ["foo-personal" "bar-work" "fred" "jones"] $result
}

export def list__ignores_spaces_at_either_end [] {
    assert equal ["fred" "jones"] (with-env {BF_WIREGUARD_PEERS: "  fred jones "} { peers list })
}

export def list__is_empty_without_peers [] {
    # no peers is valid - the server starts and peers can be added later
    assert equal [] (peers list)
    assert equal [] (with-env {BF_WIREGUARD_PEERS: ""} { peers list })
}


#======================================================================================================================
# addresses and files
#======================================================================================================================

export def increment__starts_peers_at_configured_number [] {
    with-env {BF_WIREGUARD_IP_START_PEERS_AT: "2"} {
        assert equal 2 (0 | peers increment)
        assert equal 7 (5 | peers increment)
    }
}

export def get_dir__is_in_peers_directory [] {
    assert equal "/config/peers.d/fred" (with-env {BF_WIREGUARD_PEERS_D: "/config/peers.d"} { "fred" | peers get_dir })
}

export def get_conf__returns_peer_configuration [] {
    let peers_d = mktemp --directory
    mkdir $"($peers_d)/fred"
    "[Interface]" | save $"($peers_d)/fred/config"

    assert equal "[Interface]" (with-env {BF_WIREGUARD_PEERS_D: $peers_d} { peers get_conf fred } | str trim)
}

export def get_conf__fails_for_unknown_peer [] {
    assert error { with-env {BF_WIREGUARD_PEERS_D: (mktemp --directory)} { peers get_conf fred } }
}

export def get_list__reads_saved_peers [] {
    let file = $"(mktemp --directory)/list.txt"
    [{name: "fred", public_key: "abc="}] | to nuon | save $file

    assert equal [{name: "fred", public_key: "abc="}] (with-env {BF_WIREGUARD_PEERS_LIST: $file} { peers get_list })
}


#======================================================================================================================
# clients
#======================================================================================================================

export def parse_dump__names_each_peer [] {
    let peers_list = [{name: "fred", public_key: "fredkey="} {name: "jones", public_key: "joneskey="}]
    let lines = [
        "joneskey=\tpsk=\t203.0.113.9:53121\t10.187.0.3/32\t1760000000\t1024\t2048\toff"
        "fredkey=\tpsk=\t(none)\t10.187.0.2/32\t0\t0\t0\toff"
    ]

    let result = $lines | clients parse_dump $peers_list

    assert equal ["jones" "fred"] ($result | get name)
    assert equal "203.0.113.9" $result.0.remote_ip "the client's port should be removed"
    assert equal "10.187.0.3" $result.0.virtual_ip
    assert equal 1024b $result.0.bytes_received
    assert equal 2048b $result.0.bytes_sent
    assert equal "never" $result.1.last_seen
}

export def parse_dump__fails_for_unknown_peer [] {
    let lines = ["unknownkey=\tpsk=\t(none)\t10.187.0.9/32\t0\t0\t0\toff"]

    assert error { $lines | clients parse_dump [{name: "fred", public_key: "fredkey="}] }
}

export def get_qr__encodes_peer_configuration [] {
    let peers_d = mktemp --directory
    mkdir $"($peers_d)/fred"
    "[Interface]" | save $"($peers_d)/fred/config"
    let dir = mktemp --directory
    "#!/bin/sh\nprintf '%s\\n' \"$@\" > \"$(dirname \"$0\")/args\"\n" | save $"($dir)/qrencode"
    ^chmod +x $"($dir)/qrencode"
    let path = [$dir] | append ($env.PATH | [$in] | flatten | str join (char esep) | split row (char esep))

    with-env {PATH: $path, BF_WIREGUARD_PEERS_D: $peers_d, BF_WIREGUARD_QR_ENCODING: "ansiutf8"} { peers get_qr fred }

    assert equal ["-t" "ansiutf8" "[Interface]"] (open --raw $"($dir)/args" | lines)
}
