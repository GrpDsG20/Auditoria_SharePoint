Install-Module -Name Microsoft.Online.SharePoint.PowerShell

Update-Module -Name Microsoft.Online.SharePoint.PowerShell


Connect-SPOService https://m365x14389705-admin.sharepoint.com/


# Para que este script funcione correctamente, es necesario tener permisos de Administrador de Colección de Sitios y ser Owner (propietario) en todos los sitios de SharePoint Online que se gestionen.
# ------------- Permisos de Owner en todos los sitios de SharePoint -------------

# Conectar a SharePoint Online
Connect-SPOService -Url "https://m365x14389705-admin.sharepoint.com/"

# Obtener todos los sitios de SharePoint
$sites = Get-SPOSite -Limit ALL

# Tu dirección de correo electrónico
$yourEmail = "tu_correo@ejemplo.com"

foreach ($site in $sites) {
    # Añadirte como Owner en cada sitio
    Set-SPOSite -Identity $site.Url -Owner $yourEmail
    Write-Host "Te has agregado como Owner en: $($site.Url)"
}


# ------------- Administrador de colección de sitios -------------

# Establecer conexión a SharePoint Online
$AdminCenterURL = "https://tu-tenant-admin.sharepoint.com"
Connect-SPOService -Url $AdminCenterURL

# Obtener todos los sitios
$sites = Get-SPOSite -Limit ALL

# Agregar tu cuenta como propietario a cada sitio
foreach ($site in $sites) {
    Set-SPOUser -Site $site.Url -LoginName "tu-correo@tu-dominio.com" -IsSiteCollectionAdmin $true
}



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