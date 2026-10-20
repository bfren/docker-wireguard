use std/assert


#======================================================================================================================
# helpers
#======================================================================================================================

# Generate a configuration file from its template, with the Dockerfile defaults plus $vars, and return its lines
def render [name: string, vars: record = {}]: nothing -> list<string> {
    let defaults = {
        BF_WIREGUARD_DNS: "1.1.1.1"
        BF_WIREGUARD_EXTERNAL_ADDRESS: "vpn.example.com"
        BF_WIREGUARD_IP_RANGE: "10.187.0"
    }
    let result = with-env ($defaults | merge $vars) { ^esh $"/etc/bf/templates/($name).conf.esh" | complete }
    assert equal 0 $result.exit_code $"the template should render: ($result.stderr)"
    $result.stdout | lines | str trim | where {|x| $x != "" }
}


#======================================================================================================================
# interface.conf
#======================================================================================================================

export def interface__is_first_address_in_range [] {
    let conf = render interface {SERVER_PRIVATE_KEY: "serverkey="}

    for x in ["[Interface]" "Address = 10.187.0.1/24" "ListenPort = 51820" "PrivateKey = serverkey="] {
        assert ($x in $conf) $"($x) should be set"
    }
}

export def interface__forwards_and_masquerades_traffic [] {
    let conf = render interface {SERVER_PRIVATE_KEY: "serverkey="}

    assert ($conf | any {|x| $x starts-with "PostUp =" and $x =~ "MASQUERADE" })
    assert ($conf | any {|x| $x starts-with "PostDown =" and $x =~ "MASQUERADE" })
}


#======================================================================================================================
# peer-definition.conf
#======================================================================================================================

export def peer_definition__allows_only_peer_address [] {
    let conf = render peer-definition {NAME: "fred", NUM: "2", PUBLIC_KEY: "fredkey=", PRESHARED_KEY: "psk="}

    for x in ["[Peer]" "PublicKey = fredkey=" "PresharedKey = psk=" "AllowedIPs = 10.187.0.2/32"] {
        assert ($x in $conf) $"($x) should be set"
    }
}


#======================================================================================================================
# peer-config.conf
#======================================================================================================================

export def peer_config__connects_to_external_address [] {
    let vars = {NUM: "2", PRIVATE_KEY: "fredprivate=", SERVER_PUBLIC_KEY: "serverkey=", PRESHARED_KEY: "psk="}
    let conf = render peer-config $vars

    for x in ["Address = 10.187.0.2/24" "DNS = 1.1.1.1" "PrivateKey = fredprivate=" "PublicKey = serverkey=" "PresharedKey = psk=" "Endpoint = vpn.example.com:51820"] {
        assert ($x in $conf) $"($x) should be set"
    }
}

export def peer_config__sends_all_traffic_through_vpn [] {
    let vars = {NUM: "2", PRIVATE_KEY: "a=", SERVER_PUBLIC_KEY: "b=", PRESHARED_KEY: "c="}

    assert ("AllowedIPs = 0.0.0.0/0, ::/0" in (render peer-config $vars))
}

export def peer_config__uses_range_and_dns [] {
    let vars = {NUM: "9", PRIVATE_KEY: "a=", SERVER_PUBLIC_KEY: "b=", PRESHARED_KEY: "c=", BF_WIREGUARD_IP_RANGE: "10.8.0", BF_WIREGUARD_DNS: "10.8.0.1"}
    let conf = render peer-config $vars

    assert ("Address = 10.8.0.9/24" in $conf)
    assert ("DNS = 10.8.0.1" in $conf)
}
