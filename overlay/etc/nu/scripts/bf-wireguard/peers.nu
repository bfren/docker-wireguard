use bf

# Get the list of peer names that need to be configured
export def main [] { bf env WIREGUARD_PEERS | split row -r '\s+' }

# Get the path to the peer's config directory
export def dir [
    name: string    # Peer name
] {
    $"(bf env WIREGUARD_PEERS_D)/($name)"
}

# Get the list of configured peers
export def list [] { bf env WIREGUARD_PEERS_LIST | open --raw | from nuon }

# Increment the array index by 2 to return the final number of a peer's IP address
export def num [
    index: int  # Array index of the current peer
] {
    $index + 2
}

# Return a peer's configuration settings
export def get_conf [
    name: string    # Peer name
] {
    # ensure peer config file exists
    let peer_config_file = $"(dir $name)/config"
    if ($peer_config_file | bf fs is_not_file) { bf write error $"Configuration file for ($name) does not exist." peers/show_conf }

    # read and return file contents
    bf fs read $peer_config_file
}
