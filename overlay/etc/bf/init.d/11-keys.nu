use bf
bf env load

# Generate WireGuard keys
def main [] {
    # get paths to key files
    let public_key_file = bf env WIREGUARD_SERVER_PUBLICKEY
    let private_key_file = bf env WIREGUARD_SERVER_PRIVATEKEY

    # generate the keys if they do not already exist
    if ($private_key_file | bf fs is_not_file) {
        bf write "Generating WireGuard keys."
        { ^sh -c $"umask 077 ; wg genkey | tee ($private_key_file) | wg pubkey > ($public_key_file)" } | bf handle
        return
    }

    # if we get here the keys already exist
    bf write debug "WireGuard keys already exist."
}
