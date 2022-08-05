# Pre-requisites
# Install-Module Microsoft.Graph

$tId = "nnnn" #tenant ID
$agoDays = 14 #will filter the log for $agoDays from current date/time
$startDate = (Get-Date).AddDays(-($agoDays)).ToString('yyyy-MM-dd') #calculate start date for filter
$pathForExport = ".\" #path to local filesystem for export of CSV file

Connect-MgGraph -TenantId $tId -Scopes "AuditLog.Read.All" #could also use Directory.Read.All
Select-MgProfile "beta" #Low TLS available in MS Graph preview endpoint

$signInsInteractive = Get-MgAuditLogSignIn -Filter "createdDateTime ge $startDate and (authenticationProcessingDetails/any(x:x/key eq 'legacy tls (tls 1.0, 1.1, 3des)' and x/value eq '1'))" -All
$signInsNonInteractive = Get-MgAuditLogSignIn -Filter "createdDateTime ge $startDate and signInEventTypes/any(t: t eq 'nonInteractiveUser') and (authenticationProcessingDetails/any(x:x/key eq 'legacy tls (tls 1.0, 1.1, 3des)' and x/value eq '1'))" -All
$signInsSPN = Get-MgAuditLogSignIn -Filter "createdDateTime ge $startDate and signInEventTypes/any(t: t eq 'servicePrincipal') and (authenticationProcessingDetails/any(x:x/key eq 'legacy tls (tls 1.0, 1.1, 3des)' and x/value eq '1'))" -All
$signInsManaged = Get-MgAuditLogSignIn -Filter "createdDateTime ge $startDate and signInEventTypes/any(t: t eq 'managedIdentity') and (authenticationProcessingDetails/any(x:x/key eq 'legacy tls (tls 1.0, 1.1, 3des)' and x/value eq '1'))" -All

$signInsInteractive | Foreach-Object {
    foreach ($authDetail in $_.AuthenticationProcessingDetails)
    {
        if(($authDetail.Key -match "Legacy TLS") -and ($authDetail.Value -eq "True")){
            $_ | select CorrelationId, createdDateTime, userPrincipalName, userId, UserDisplayName, AppDisplayName, AppId, IPAddress, isInteractive, ResourceDisplayName, ResourceId 
        }
    }

} | Export-Csv -NoTypeInformation -Path ($pathForExport + "Interactive_lowTls_$tId.csv")

$signInsNonInteractive | Foreach-Object {
    foreach ($authDetail in $_.AuthenticationProcessingDetails)
    {
        if(($authDetail.Key -match "Legacy TLS") -and ($authDetail.Value -eq "True")){
            $_ | select CorrelationId, createdDateTime, userPrincipalName, userId, UserDisplayName, AppDisplayName, AppId, IPAddress, isInteractive, ResourceDisplayName, ResourceId 
        }
    }

} | Export-Csv -NoTypeInformation -Path ($pathForExport + "NonInteractive_lowTls_$tId.csv")
$signInsSPN | Foreach-Object {
    foreach ($authDetail in $_.AuthenticationProcessingDetails)
    {
        if(($authDetail.Key -match "Legacy TLS") -and ($authDetail.Value -eq "True")){
            $_ | select CorrelationId, createdDateTime, userPrincipalName, userId, UserDisplayName, AppDisplayName, AppId, IPAddress, isInteractive, ResourceDisplayName, ResourceId 
        }
    }

} | Export-Csv -NoTypeInformation -Path ($pathForExport + "SPN_lowTls_$tId.csv")
$signInsManaged | Foreach-Object {
    foreach ($authDetail in $_.AuthenticationProcessingDetails)
    {
        if(($authDetail.Key -match "Legacy TLS") -and ($authDetail.Value -eq "True")){
            $_ | select CorrelationId, createdDateTime, userPrincipalName, userId, UserDisplayName, AppDisplayName, AppId, IPAddress, isInteractive, ResourceDisplayName, ResourceId 
        }
    }

} | Export-Csv -NoTypeInformation -Path ($pathForExport + "Managed_lowTls_$tId.csv")