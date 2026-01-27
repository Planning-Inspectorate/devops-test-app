param(
  [Parameter(Mandatory=$true)] [string]$To,
  [switch]$Send
)

# Uses Outlook if available to compose/send an email with the cheatsheet HTML.
# - Run without -Send to review the email; add -Send to send immediately.
# - Ensure Outlook is installed and configured on this machine.

$repoRoot = Split-Path -Path $PSScriptRoot -Parent
$htmlPath = Join-Path $repoRoot 'docs/git-onepager.html'
if (-not (Test-Path $htmlPath)) {
  Write-Error "Cheatsheet not found at $htmlPath"
  exit 1
}

$html = Get-Content -Path $htmlPath -Raw

try {
  $outlook = New-Object -ComObject Outlook.Application
} catch {
  Write-Error "Outlook COM interface not available. Open $htmlPath and send manually, or use SMTP."
  exit 1
}

$mail = $outlook.CreateItem(0)
$mail.To = $To
$mail.Subject = 'Easy Git Cheatsheet'
$mail.HTMLBody = $html

if ($Send) {
  $mail.Send()
  Write-Output "Sent to $To"
} else {
  $mail.Display()
  Write-Output "Draft opened in Outlook for $To"
}

# Optional: SMTP example (commented)
# Send-MailMessage -To $To -From you@example.com -Subject 'Easy Git Cheatsheet' -Body $html -BodyAsHtml -SmtpServer smtp.example.com
