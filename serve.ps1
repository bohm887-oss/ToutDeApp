$ErrorActionPreference = "Stop"
$port = if ($env:PORT) { $env:PORT } else { "3000" }
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Serving the app at http://localhost:$port/"

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $path = $context.Request.Url.AbsolutePath
        $file = switch ($path) {
            "/" { Join-Path $PSScriptRoot "index.html" }
            "/style.css" { Join-Path $PSScriptRoot "style.css" }
            default { $null }
        }

        if ($null -eq $file) {
            $context.Response.StatusCode = 404
            $body = [System.Text.Encoding]::UTF8.GetBytes("Not found")
        }
        else {
            $context.Response.StatusCode = 200
            $context.Response.ContentType = if ($path -eq "/") { "text/html; charset=utf-8" } else { "text/css; charset=utf-8" }
            $body = [System.IO.File]::ReadAllBytes($file)
        }

        $context.Response.ContentLength64 = $body.Length
        $context.Response.OutputStream.Write($body, 0, $body.Length)
        $context.Response.Close()
    }
}
finally {
    $listener.Stop()
}
