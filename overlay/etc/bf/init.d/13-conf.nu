use bf
use bf-wireguard peers
bf env load

# Generate WireGuard configuration file
def main [] {
    # get values as variables
    let conf = bf env WIREGUARD_CONF
    let server_private_key = bf fs read (bf env WIREGUARD_SERVER_PRIVATEKEY)

    # generate the interface configuration
    bf write "Generating WireGuard configuration file."
    with-env { SERVER_PRIVATE_KEY: $server_private_key } {
        bf esh $"(bf env ETC_TEMPLATES)/interface.conf.esh" $conf
    }

    # add each peer to the interface configuration
    bf write "Adding peers."
    let peers_list = bf env WIREGUARD_PEERS | split words
    peers | enumerate | each {|x|
        # read info for this peer
        let name = $x.item
        let num = $x.index | peers increment

        let peer_d = $name | peers get_dir
        let public_key = bf fs read $"($peer_d)/(bf env WIREGUARD_PEER_PUBLICKEY_FILE)"
        let preshared_key = bf fs read $"($peer_d)/(bf env WIREGUARD_PEER_PRESHAREDKEY_FILE)"

        # add this peer to the configuration file
        bf write $" .. ($name) [($num)]"
        bf write debug "    adding peer definition to configuration file"
        with-env { NAME: $name, NUM: $num, PUBLIC_KEY: $public_key, PRESHARED_KEY: $preshared_key } {
            bf esh $"(bf env ETC_TEMPLATES)/peer-definition.conf.esh" | $"(char newline)($in)(char newline)" | save --append $conf
        }
    }

    # set permissions
    bf ch --mode 0400 $conf
}
