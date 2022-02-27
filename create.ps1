function CreateProject {
    [CmdletBinding()]
    param(
        [int]$i
    )

    [xml]$doc = Get-Content 'template.xml'

    $itemGroup = $doc.CreateElement('ItemGroup')
    $doc.Project.AppendChild($itemGroup)

    For ($j = 1; $j -lt $i; $j++) {
        $projReference = $doc.CreateElement('ProjectReference')
        $projReference.SetAttribute('Include', "..\ClassLibrary${j}\ClassLibrary${j}.csproj")

        $itemGroup.AppendChild($projReference)
    }

    $noWarn = $doc.CreateElement('NoWarn')
    $noWarn.InnerText = '$(NoWarn);NU1001;NU1002;NU1003;' + $i.ToString("NU100") + '0'
    $doc.Project.PropertyGroup.AppendChild($noWarn)

    $settings = New-Object -TypeName 'System.Xml.XmlWriterSettings' -Property @{Indent=$true; OmitXmlDeclaration=$true}
    $writer = [System.Xml.XmlWriter]::Create("src\ClassLibrary${i}\ClassLibrary${i}.csproj", $settings)

    try
    {
        $doc.Save($writer)
    }
    finally
    {
        $writer.Dispose();
    }
}

mkdir 'src'

For ($i = 1; $i -lt 43; $i++) {
    mkdir "src\ClassLibrary${i}"
    CreateProject -i $i
}

dotnet new sln --output src --name LotsOfDependencies
dotnet sln src\LotsOfDependencies.sln add (Get-ChildItem -r **/*.csproj)
