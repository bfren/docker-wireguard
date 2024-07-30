use bf
use bf-wireguard peers
bf env load

# Generate WireGuard peers keys and configuration
def main [] {
    bf write "Generating peer keys and configuration."

    # get server public key
    let server_public_key = bf fs read (bf env WIREGUARD_SERVER_PUBLICKEY)

    # ensure peers directory exists
    let peers_d = bf env WIREGUARD_PEERS_D
    mkdir $peers_d

    # loop using index for calculating the peer IP address
    let peers_list = peers | enumerate | each {|x|
        # get variables for easy access
        let name = $x.item
        let num = $x.index | peers increment
        bf write $" .. ($name) [($num)]"

        # if peer number is greater than 254, exit with an error
        if $num >= 254 { bf write error "You have requested too many peers." }

        # ensure peer directory exists
        let peer_d = $name | peers get_dir
        mkdir $peer_d

        # if the public and private keys do not exist, create them
        let public_key_file = $"($peer_d)/(bf env WIREGUARD_PEER_PUBLICKEY_FILE)"
        let private_key_file = $"($peer_d)/(bf env WIREGUARD_PEER_PRIVATEKEY_FILE)"
        if ($public_key_file | bf fs is_not_file) or ($private_key_file | bf fs is_not_file) {
            bf write debug "    public and private keys"
            { ^sh -c $"wg genkey | tee ($private_key_file) | wg pubkey > ($public_key_file)" } | bf handle
        }

        # if the preshared key does not exist, create it
        let preshared_key_file = $"($peer_d)/(bf env WIREGUARD_PEER_PRESHAREDKEY_FILE)"
        if ($preshared_key_file | bf fs is_not_file) {
            bf write debug "    preshared key"
            { ^sh -c $"wg genpsk | tee ($preshared_key_file) &> /dev/null" } | bf handle
        }

        # always generate config in case IP range / DNS has changed
        let public_key = bf fs read $public_key_file
        let preshared_key = bf fs read $preshared_key_file
        let private_key = bf fs read $private_key_file
        with-env { NUM: $num, SERVER_PUBLIC_KEY: $server_public_key, PRESHARED_KEY: $preshared_key, PRIVATE_KEY: $private_key } {
            bf write debug "    configuration file"
            bf esh $"(bf env ETC_TEMPLATES)/peer-config.conf.esh" $"($peer_d)/config"
        }

        # add peer name to list for showing stats
        let public_key = bf fs read $public_key_file
        bf write debug "    adding to peers list"
        { name: $name, public_key: $public_key }
    }

    # save peers list to file
    bf write $" .. saving list of peers"
    $peers_list | to nuon | save --force (bf env WIREGUARD_PEERS_LIST)
}
