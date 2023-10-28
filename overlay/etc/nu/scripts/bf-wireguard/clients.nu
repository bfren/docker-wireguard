use bf
use peers.nu

export def main [] {
    # if there are no peers in the list, exit
    let peers_list = peers get_list
    if ($peers_list | length) == 0 { bf write notok "There are no clients to list." ; exit 0 }

    # get list of current clients from wg tools
    let clients_list = { ^wg show (bf env WIREGUARD_INTERFACE) dump } | bf handle -i | lines
    if ($clients_list | length) == 0 { bf write error "Unable to get the list of clients." }

    # convert each line into a record
    # skip the first one which is the server instance, not a client
    $clients_list | skip 1 | each {|x|
        # split by spaces
        let col = $x | split row -r '\s+'

        # read values as variables
        let public_key = $col.0
        let remote_ip = $col.2
        let virtual_ip = $col.3
        let last_seen = $col.4 | into datetime
        let bytes_received = $col.5 | into filesize
        let bytes_sent = $col.6 | into filesize
        let name = match ($peers_list | where public_key == $public_key) {
            $x if ($x | length) == 1 => { $x | first | get name }
            _ => { bf write error $"Unable to find peer with public key ($public_key)." clients }
        }

        # return as a record
        {name: $name, remote_ip: $remote_ip, virtual_ip: $virtual_ip, bytes_received: $bytes_received, bytes_sent: $bytes_sent, last_seen: $last_seen}
    }
}
