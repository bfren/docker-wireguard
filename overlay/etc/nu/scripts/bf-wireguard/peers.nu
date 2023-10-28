# Get the path to the peer's config directory
export def dir [
    name: string    # Peer name
] {
    $"(bf env WIREGUARD_PEERS_D)/($name)"
}

# Get the list of peers
export def list [] { bf env WIREGUARD_PEERS | split row -r '\s+' }

# Increment the array index by 2 to return the final number of a peer's IP address
export def num [
    index: int  # Array index of the current peer
] {
    $index + 2
}
