use bf
bf env load

# Set environment variables
def main [] {

    let conf_d = "/config"
    bf env set WIREGUARD_CONF_D $conf_d
    bf env set WIREGUARD_CONF $"($conf_d)/(bf env WIREGUARD_INTERFACE).conf"
    bf env set WIREGUARD_SERVER_PRIVATEKEY $"($conf_d)/privatekey"
    bf env set WIREGUARD_SERVER_PUBLICKEY $"($conf_d)/publickey"

    let peers_d = $"($conf_d)/peers.d"
    bf env set WIREGUARD_PEERS_D $peers_d
    bf env set WIREGUARD_PEERS_LIST $"($peers_d)/list.txt"
    bf env set WIREGUARD_PEER_PRIVATEKEY_FILE privatekey
    bf env set WIREGUARD_PEER_PUBLICKEY_FILE publickey
    bf env set WIREGUARD_PEER_PRESHAREDKEY_FILE presharedkey

    bf env set WIREGUARD_QR_ENCODING ansiutf8

    # return nothing
    return
}
