<#
.SYNOPSIS
    Entra ID LAPS Self-Service Tool (PowerShell GUI)
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ==========================================
# CONFIGURATION
# ==========================================
$ClientId = "7798bc2a-3dbf-403f-97a0-1216dd273bf1"
$TenantId = "cefd98c3-0938-485a-8e76-e762afa8c340"
$Scopes   = @("DeviceLocalCredential.Read.All", "Device.Read.All")
# ==========================================

$Form = New-Object System.Windows.Forms.Form
$Form.Text = "LAPS Password Retriever"
$Form.Size = New-Object System.Drawing.Size(450, 300)
$Form.StartPosition = "CenterScreen"
$Form.FormBorderStyle = "FixedDialog"
$Form.MaximizeBox = $false

$FontLabel = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$FontText  = New-Object System.Drawing.Font("Segoe UI", 9)

$TitleLabel = New-Object System.Windows.Forms.Label
$TitleLabel.Text = "Local Machine LAPS Password"
$TitleLabel.Location = New-Object System.Drawing.Point(15, 15)
$TitleLabel.Size = New-Object System.Drawing.Size(400, 25)
$TitleLabel.Font = $FontLabel
$Form.Controls.Add($TitleLabel)

$ResultBox = New-Object System.Windows.Forms.TextBox
$ResultBox.Location = New-Object System.Drawing.Point(15, 50)
$ResultBox.Size = New-Object System.Drawing.Size(400, 80)
$ResultBox.Font = New-Object System.Drawing.Font("Consolas", 12)
$ResultBox.Multiline = $true
$ResultBox.ReadOnly = $true
$ResultBox.TextAlign = "Center"
$Form.Controls.Add($ResultBox)

$FetchButton = New-Object System.Windows.Forms.Button
$FetchButton.Text = "Sign In & Get Password"
$FetchButton.Location = New-Object System.Drawing.Point(15, 160)
$FetchButton.Size = New-Object System.Drawing.Size(400, 40)
$FetchButton.Font = $FontLabel
$FetchButton.BackColor = [System.Drawing.Color]::LightBlue
$Form.Controls.Add($FetchButton)

$FetchButton.Add_Click({
    $ResultBox.Text = "Identifying machine..."
    
    try {
        $dsreg = dsregcmd /status
        $deviceIdLine = $dsreg | Select-String "DeviceId"
        if (-not $deviceIdLine) { 
            $ResultBox.Text = "Error: Machine is not Entra Joined."
            return 
        }
        $adDeviceId = $deviceIdLine.ToString().Split(":")[1].Trim()

        $ResultBox.Text = "Connecting to Entra ID..."
        Connect-MgGraph -ClientId $ClientId -TenantId $TenantId -Scopes $Scopes -ContextScope Process -NoWelcome
        
        $ResultBox.Text = "Fetching password..."
        $Url = "https://graph.microsoft.com/v1.0/directory/deviceLocalCredentials/$adDeviceId" + '?$select=credentials'
        $Response = Invoke-MgGraphRequest -Method GET -Uri $Url

        if ($Response.credentials) {
            $PwdB64 = $Response.credentials[0].passwordBase64
            $DecodedPwd = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($PwdB64))
            $ResultBox.Text = "`r`n$DecodedPwd"
            [System.Windows.Forms.Clipboard]::SetText($DecodedPwd)
            [System.Windows.Forms.MessageBox]::Show("Password found and copied to clipboard!", "Success")
        } else {
            $ResultBox.Text = "No LAPS password found for this machine."
        }
    } catch {
        $ResultBox.Text = "Error: $($_.Exception.Message)"
    }
})

$Form.ShowDialog()
