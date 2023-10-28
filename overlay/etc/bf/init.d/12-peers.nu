use bf
use bf-wireguard peers
bf env load

# Generate WireGuard peers keys and configuration
def main [] {
    bf write "Generating peer keys and configuration."

    # ensure peers directory exists
    let peers_d = bf env WIREGUARD_PEERS_D
    mkdir $peers_d

    # remove list of peers - it will be remade during the loop
    let peers_list_file = bf env WIREGUARD_PEERS_LIST
    rm --force $peers_list_file

    # loop using index for calculating the peer IP address
    for peer in (peers list) --numbered {
        # get variables for easy access
        let name = $peer.item
        let num = peers num $peer.index
        bf write $" .. ($name) [($num)]"

        # if peer number is greater than 254, exit with an error
        if $num >= 254 { bf write error "You have requested too many peers." }

        # ensure peer directory exists
        let peer_d = peers dir $name
        if ($peer_d | bf fs is_not_dir) { mkdir $peer_d }

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
        with-env {NUM: $num, PUBLIC_KEY: $public_key, PRESHARED_KEY: $preshared_key, PRIVATE_KEY: $private_key} {
            bf write debug "    configuration file"
            bf esh $"(bf env ETC_TEMPLATES)/peer-config.conf.esh" $"($peer_d)/config"
        }

        # add peer name to list for showing stats
        let public_key = bf fs read $public_key_file
        bf write debug "    adding to peers list file"
        $"($name) ($public_key) ($num)(char newline)" | save --append $peers_list_file
    }
}
