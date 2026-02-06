function Show-Tree {
    param (
        [string]$Path = ".",
        [string[]]$ExcludeTopLevel = @(),
        [int]$Level = 0
    )
    # Capturar la salida en una lista
    $output = @()
    
    # Solo al nivel raíz listamos TODOS los ficheros en la raíz
    if ($Level -eq 0) {
        $rootFiles = Get-ChildItem -Path $Path -File
        foreach ($file in $rootFiles) {
            $prefix = if ($file.Length -le 3) { "* " } else { "" }
            $output += "├── " + $prefix + $file.Name
        }
    }    

    # Obtener elementos, aplicando exclusión solo en el primer nivel
    if ($Level -eq 0) {
        $items = Get-ChildItem -Path $Path -Exclude $ExcludeTopLevel -File
    } else {
        $items = Get-ChildItem -Path $Path -File
    }
    
    foreach ($item in $items) {
        if ($Level -ne 0) { # Evitar duplicar los ficheros del nivel raíz
            $prefix = if ($item.Length -le 3) { "* " } else { "" }
            $line = "  " + "  " * $Level + "├── " + $prefix + $item.Name
            $output += $line
        }
    }
    
    # Obtener subdirectorios para continuar la recursión
    if ($Level -eq 0) {
        $dirs = Get-ChildItem -Path $Path -Directory -Exclude $ExcludeTopLevel
    } else {
        $dirs = Get-ChildItem -Path $Path -Directory
    }
    
    foreach ($dir in $dirs) {
        # Mostrar el directorio siempre (ya no filtramos por archivos no vacíos)
        $subItems = Show-Tree -Path $dir.FullName -ExcludeTopLevel $ExcludeTopLevel -Level ($Level + 1)
        $output += "  " * $Level + "├── " + $dir.Name
        if ($subItems) {
            $output += $subItems
        }
    }
    
    return $output
}

# Ejecutar la función y mostrar la salida
Show-Tree -Path . -ExcludeTopLevel "android","build","ios","linux","macos","web","windows",".dart_tool",".idea","tareas_gemini",".vscode",".git"