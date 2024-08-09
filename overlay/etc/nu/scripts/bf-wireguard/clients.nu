use bf
use peers.nu

# Get all connected clients
export def main []: nothing -> list<record> {
    # if there are no peers in the list, exit
    let peers_list = peers get_list
    if ($peers_list | length) == 0 { bf write notok "There are no clients to list." ; exit 0 }

    # get list of current clients from wg tools
    let clients_list = { ^wg show (bf env WIREGUARD_INTERFACE) dump } | bf handle -i clients | lines
    if ($clients_list | length) == 0 { bf write error "Unable to get the list of clients." }

    # convert each line into a record
    # skip the first one which is the server instance, not a client
    $clients_list | skip 1 | each {|x|
        # split by spaces
        let col = $x | split row -r '\s+'

        # parse and return values as a record
        {
            name: (match ($peers_list | where public_key == $col.0) {
                $x if ($x | length) == 1 => { $x | first | get name }
                _ => { bf write error $"Unable to find peer with public key ($col.0)." clients }
            }),
            remote_ip: ($col.2 | str replace ":51820" ""),
            virtual_ip: ($col.3 | str replace "/32" ""),
            bytes_received: ($col.5 | into filesize),
            bytes_sent: ($col.6 | into filesize),
            last_seen: ($col.4 | into int | match $in { $x if $x > 0 => ($x * 1_000_000_000 | into datetime), _ => "never" })
        }
    }
}

# Show the list of peers with public keys replaced by peer names
def show []: nothing -> nothing {
    # get the output from wg executable
    let output = { ^wg show } | bf handle -i peers/show
    if ($output | is-empty) { bf write error "WireGuard interface not detected." }

    # replace public keys with peer names
    let result = peers get_list | reduce --fold $output {|peer, acc|
        $acc | str replace $peer.public_key $peer.name
    }

    # display result
    $result | print
}

# Show the list of peers and refresh every
export def watch [
    refresh: duration = 2sec    # Refresh the list by this duration
]: nothing -> nothing {
    loop { clear ; show ; sleep $refresh }
}
