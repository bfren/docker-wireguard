use dump.nu
use write.nu

# Load a URL, outputting any errors or OK on success
export def load_url [
    url: string # URL to load
] {
    # allow http errors to be printed to give as much info as possible to calling script
    write debug $"Testing ($url)." http/test_url
    http get $url

    # if we get here the URL was loaded successfully
    write debug " .. OK" http/test_url
}

# Test a URL and return whether or not it gives an error HTTP status code
export def test_url [
    url: string             # URL to load
    --return-status (-s)    # Enable to return status instead of false
] {
    let status = try { http get --allow-errors --full $url | get status } catch { 400 }
    if $return_status { $status } else { $status >= 200 and $status <= 399 }
}
