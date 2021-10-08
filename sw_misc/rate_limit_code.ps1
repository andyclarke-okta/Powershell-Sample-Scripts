function Get-Headers {
    $urlLimit = 1200 # this varies by URL
    $remaining = $urlLimit
    for ($i = 1; $i -le 5000; $i++) {
        $now = [DateTimeOffset]::Now.ToUnixTimeSeconds()
        if ($remaining -gt 20) {
            try {
                $page = Get-OktaUsers -filter 'profile.login eq "gabriel.sroka@lokta.com"'
                $limit = [int64]$page.response.Headers.'X-Rate-Limit-Limit'
                $remaining = [int64]$page.response.Headers.'X-Rate-Limit-Remaining'
                $reset = [int64]$page.response.Headers.'X-Rate-Limit-Reset'
                Write-Host "now: " + $now + " remaining: " + $remaining + " reset: " + $reset
            } catch {
                Write-Host "Error ! (need to redo last call)."
                $remaining = 0
            }
        } else {
            Write-Host "waiting, now: " + $now + " reset: " + $reset
            if ($now -gt $reset) {
                Write-Host "reset"
                $remaining = $urlLimit
            }
            Start-Sleep -second 1
        }
    }
}
