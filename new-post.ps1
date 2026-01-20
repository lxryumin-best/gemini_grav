<#
Grav + Gemini automation script with frontmatter.
Generates SEO-optimized pages with full metadata.

Example:
.\new-post.ps1 `
  -Title "White Paper Always-On CCTV" `
  -Prompt "Explain benefits of agent-based CCTV monitoring for MSPs" `
  -ServerUser "root" `
  -ServerIP "Example.com" `
  -Port 22 `
  -ParentFolder "01.whitepapers"
#>

param(
    [Parameter(Mandatory = $true)][string]$Title,
    [Parameter(Mandatory = $true)][string]$Prompt,
    [Parameter(Mandatory = $true)][string]$ServerUser,
    [Parameter(Mandatory = $true)][string]$ServerIP,
    [Parameter(Mandatory = $false)][int]$Port = 22,
    [Parameter(Mandatory = $false)][string]$ParentFolder = "01.home"
)

chcp 65001 > $null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$RemoteBaseDir = "/opt/grav-site/site-data/www/user/pages"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm"
$Slug = $Title.ToLower() -replace '[^a-z0-9]', '-' -replace '-+', '-' -replace '^-|-$', ''
if (-not $Slug) { $Slug = "page-" + (Get-Random -Maximum 999999) }

$FileName = "item.md"
$LocalTempFile = Join-Path $env:TEMP "grav_temp_$Slug.md"

# Auto menu title (first 3 words, max 30 chars)
$Words = $Title -split '\s+', 4
$MenuTitle = ($Words[0..2] -join ' ')
if ($MenuTitle.Length -gt 30) { $MenuTitle = $MenuTitle.Substring(0, 27) + '...' }

# FIXED prompt - NO tools, full SEO metadata
$SystemInstruction = @"
You are a technical writer for Grav CMS site.

CRITICAL: Output ONLY raw markdown. NO tools, NO code blocks.

EXACT FORMAT:
---
title: $Title
menu: '$MenuTitle'
published: true
visible: true
date: '$Date'
taxonomy:
    category: blog
    tag: []
metadata:
    description: [150-160 chars SEO description with keywords]
    keywords: [5-8 keywords/phrases, comma separated, no brackets]
slug: $Slug
---

After frontmatter: article content in markdown.
"@

$FullPrompt = "$SystemInstruction`n`nTOPIC: $Prompt"

Write-Host "Generating article..."
$Output = gemini $FullPrompt

if (-not $Output) {
    Write-Error "Gemini failed"
    exit 1
}

[System.IO.File]::WriteAllLines($LocalTempFile, $Output, [System.Text.Encoding]::UTF8)
Write-Host "Temp file OK: $LocalTempFile"

$RemotePath = "$RemoteBaseDir/$ParentFolder/$Slug"
Write-Host "Creating: $RemotePath"

# FIXED: simple mkdir without complex quoting
& ssh -p $Port ("{0}@{1}" -f $ServerUser, $ServerIP) "mkdir -p $RemotePath"

if ($LASTEXITCODE -eq 0) {
    Write-Host "Uploading..."
    $ScpTarget = "{0}@{1}:{2}/{3}" -f $ServerUser, $ServerIP, $RemotePath, $FileName
    & scp -P $Port $LocalTempFile $ScpTarget
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SUCCESS! $ParentFolder/$Slug" -ForegroundColor Green
        Write-Host "Menu: $MenuTitle" -ForegroundColor Cyan
    } else {
        Write-Error "SCP failed"
    }
} else {
    Write-Error "SSH mkdir failed - check path/permissions"
}

if (Test-Path $LocalTempFile) { Remove-Item $LocalTempFile }
