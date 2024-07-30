use bf

# Run preflight checks before executing process
export def preflight []: nothing -> nothing {
    # load environment
    bf env load

    # manually set executing script
    bf env x_set --override run wireguard

    # if we get here we are ready to start WireGuard
    bf write "Starting WireGuard interface."
}
