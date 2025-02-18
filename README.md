Para que este script funcione correctamente, es necesario tener permisos de Administrador de Colección de Sitios y ser Owner (propietario) 
en todos los sitios de SharePoint Online que se gestionen.

------------- Permisos de Owner en todos los sitios de SharePoint -------------

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


------------- Administrador de colección de sitios -------------

# Establecer conexión a SharePoint Online
$AdminCenterURL = "https://tu-tenant-admin.sharepoint.com"
Connect-SPOService -Url $AdminCenterURL

# Obtener todos los sitios
$sites = Get-SPOSite -Limit ALL

# Agregar tu cuenta como propietario a cada sitio
foreach ($site in $sites) {
    Set-SPOUser -Site $site.Url -LoginName "tu-correo@tu-dominio.com" -IsSiteCollectionAdmin $true
}
