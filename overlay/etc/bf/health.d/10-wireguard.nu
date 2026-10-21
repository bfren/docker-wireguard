use bf
bf env load -x

# Check WireGuard is listening on the correct port
def main [] {
    let show = { ^wg show } | bf handle -i
    if not ($show | str contains "listening port: 51820") { exit 1 }
}
