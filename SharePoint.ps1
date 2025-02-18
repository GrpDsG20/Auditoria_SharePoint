Install-Module -Name Microsoft.Online.SharePoint.PowerShell

Update-Module -Name Microsoft.Online.SharePoint.PowerShell


Connect-SPOService https://m365x14389705-admin.sharepoint.com/

# Verificar el estado del sitio: Puedes revisar si el sitio está en modo de solo lectura o si está en proceso de eliminación utilizando PowerShell
Get-SPOSite -Identity $site.Url | Select ReadOnly, LockState

# Levantar el bloqueo si tienes permisos
Set-SPOSite -Identity $site.Url -LockState Unlock

# Parameters
$AdminCenterURL = "https://m365x14389705-admin.sharepoint.com/"
$exportPath = "C:\Users\Usuario\Downloads\Smith\scriptSites.csv"

# Function to scan and collect Document Inventory
Function Get-SitesInventory {
    param($adminURL)
    Connect-SPOService -url $AdminCenterURL
    # Obtener todos los sitios con su URL, Owner, y Título
    $sites = Get-SPOSite -limit ALL | Select URL, Owner, Title
    return $sites
}

# Function to retrieve users and their roles from each site
Function GetUsersAndRoles {
    param($sites, $AdminCenterURL)
    Connect-SPOService -url $AdminCenterURL
    $rolesInfo = @()

    foreach($site in $sites) {
        try {
            # Intentar obtener grupos y usuarios del sitio
            $siteGroups = Get-SPOSiteGroup -site $site.Url

            foreach ($group in $siteGroups) {
                # Obtener los usuarios de cada grupo
                $users = Get-SPOUser -Site $site.Url -Group $group.Title

                # Crear un objeto para almacenar la información
                foreach ($user in $users) {
                    $rolesInfo += New-Object PSObject -Property (@{
                        Site   = $site.Title
                        URL    = $site.Url  # Agregando la URL del sitio
                        Group  = $group.Title
                        User   = $user.LoginName
                        Role   = $group.Roles -join ", "
                    })
                }
            }
        } catch {
            # Si hay un error, lo muestra y continúa con el siguiente sitio
            Write-Host "Error en el sitio $($site.Url): $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    return $rolesInfo
}

# Function to export data to CSV
Function ExportToCSV {
    param($dataArray, $pathToExport)
    $dataArray | Export-Csv -Path $pathToExport -NoTypeInformation
}

# Obtener inventario de sitios
$operationResult = Get-SitesInventory -adminURL $AdminCenterURL

# Obtener usuarios y roles para cada sitio
$usersAndRoles = GetUsersAndRoles -sites $operationResult -AdminCenterURL $AdminCenterURL

# Exportar los resultados a CSV
ExportToCSV -dataArray $usersAndRoles -pathToExport $exportPath