use bf

# Get the list of peer names that need to be configured
export def main []: nothing -> list<string> { bf env WIREGUARD_PEERS | split row -r '\s+' }

# Get the path to the peer's config directory
export def get_dir []: string -> string { $"(bf env WIREGUARD_PEERS_D)/($in)" }

# Get the list of configured peers
export def get_list []: nothing -> list<record> { bf env WIREGUARD_PEERS_LIST | open --raw | from nuon }

# Increment the array index by BF_WIREGUARD_IP_START_AT to return the final number of a peer's IP address
export def increment []: int -> int { $in + (bf env WIREGUARD_IP_START_PEERS_AT | into int) }

# Return a peer's configuration settings
export def get_conf [
    name: string    # Peer name
]: nothing -> string {
    # ensure peer config file exists
    let peer_config_file = $"($name | get_dir)/config"
    if ($peer_config_file | bf fs is_not_file) { bf write error $"Configuration file for ($name) does not exist." peers/show_conf }

    # read and return file contents
    bf fs read $peer_config_file
}

# Get a QR code of the configuration for peer $name
export def get_qr [
    name: string    # Peer name
]: nothing -> nothing {
    # get configuration
    let encoding = bf env WIREGUARD_QR_ENCODING
    let config = get_conf $name

    # convert to QR code
    { ^qrencode -t $encoding $config } | bf handle peers/get_qr
}
