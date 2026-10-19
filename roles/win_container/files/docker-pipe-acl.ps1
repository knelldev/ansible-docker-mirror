# Define the named pipe's path
$pipeName = "//./pipe/docker_engine"
$identity = "$env:computername\docker-users"

$maxRetries = 3000
$retryDelay = 100 # 0,1 second delay

for ($i = 0; $i -lt $maxRetries; $i++) {
    try {
        $acl = Get-Acl $pipeName
        break # Exit the loop if successful
    } catch {
        if ($_.Exception.Message -match "error code 231") { # Check for Error 231 in the message
            if ($i -lt $maxRetries - 1) {
                Start-Sleep -Milliseconds $retryDelay
            } else {
                Write-Error "Failed to get ACL after $maxRetries retries. Pipe is likely busy."
            }
        } else {
            throw # Re-throw other exceptions
        }
    }
}

if ($acl) {
  # Display or further process the ACL
  $acl | Format-Table -AutoSize

  # Set properties
  $fileSystemRights = "FullControl"
  $type = "Allow"
  # Create new rule
  $fileSystemAccessRuleArgumentList = $identity, $fileSystemRights, $type
  $fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList
  # Apply new rule
  $acl.SetAccessRule($fileSystemAccessRule)
  Set-Acl -Path $pipename -AclObject $acl
}
