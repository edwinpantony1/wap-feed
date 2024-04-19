param(
    [string]$WebSitesFeedLink,
    [string]$OfflineFeedsLocation = [System.Environment]::ExpandEnvironmentVariables("%SystemDrive%\Offline_Feeds")
)

# Variables previously included
$MainWebPiFeedUrl = "http://go.microsoft.com/?linkid=9823756"
$WebSitesFeedFileName = "WebSites0.9.0.xml"
$BootstrapperFeedFileName = "BootstrapperEntries.xml"
$WebPiCmdLog = "CreateOfflineFeed.log"
$transcriptLog = Join-Path $OfflineFeedsLocation "OfflineWebSitesFeed.log"

# XML Namespace Manager setup for processing XML files
$nsMgr = New-Object System.Xml.XmlNamespaceManager (New-Object System.Xml.NameTable)
$nsMgr.AddNamespace("a", "http://www.w3.org/2005/Atom")

function LogInfo([string] $text)
{
    $currentTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "$currentTimestamp - $text"
    Add-Content -Path $transcriptLog -Value "$currentTimestamp - $text"
}

function DownloadFile([string] $url, [string] $destinationPath) {
    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($url, $destinationPath)
        LogInfo "Downloaded $url successfully to $destinationPath."
    }
    catch {
        LogInfo "Failed to download $($url): $_"
        Throw
    }
    finally {
        $webClient.Dispose()
    }
}

# Ensure the offline feeds directory exists
if (-not (Test-Path -Path $OfflineFeedsLocation)) {
    New-Item -Path $OfflineFeedsLocation -ItemType Directory
}

# Define paths for the feed files
$webSitesFeedPath = Join-Path -Path $OfflineFeedsLocation -ChildPath $WebSitesFeedFileName
$bootstrapperFeedPath = Join-Path -Path $OfflineFeedsLocation -ChildPath $BootstrapperFeedFileName

# Download the website and bootstrapper feeds
if ($WebSitesFeedLink) {
    DownloadFile -url $WebSitesFeedLink -destinationPath $webSitesFeedPath
} else {
    LogInfo "No WebSites feed link provided. Attempting to download from main feed URL."
    DownloadFile -url $MainWebPiFeedUrl -destinationPath $webSitesFeedPath
}

# Assuming you have a direct link for the bootstrapper feed, this can be updated to a real URL
# DownloadFile -url "http://example.com/path/to/BootstrapperEntries.xml" -destinationPath $bootstrapperFeedPath

LogInfo "All files have been downloaded to $OfflineFeedsLocation."
