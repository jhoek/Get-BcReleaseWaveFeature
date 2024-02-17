function Get-BcReleaseWaveFeature
{
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [string]$Wave
    )

    $EnUsCulture = Get-Culture 'en-US'

    $Url = "https://learn.microsoft.com/en-us/dynamics365/release-plan/$Wave/smb/dynamics365-business-central/planned-features"
    if ($Wave -lt '2023wave1') { $Url = "https://learn.microsoft.com/en-us/dynamics365-release-plan/$Wave/smb/dynamics365-business-central/planned-features" }

    $Document = ConvertTo-HtmlDocument -Uri $Url
    $Sections = $Document | Select-HtmlNode -CssSelector 'h2:not(.title)' -All | ForEach-Object { $_ | Get-HtmlNodeText }
    $Tables = $Document | Select-HtmlNode -CssSelector 'table' -All

    0..($Sections.Length - 1) | ForEach-Object {
        $Section = $Sections[$_]
        $Table = $Tables[$_]
        $Rows = $Table | Select-HtmlNode -CssSelector 'tr' -All

        $Rows.ForEach{
            $Cells = $_ | Select-HtmlNode -CssSelector 'td' -All

            if ($Cells)
            {
                $Feature = $Cells[0] | Get-HtmlNodeText
                $EnabledFor = $Cells[1] | Get-HtmlNodeText
                $PublicPreviewText = $Cells[2] | Get-HtmlNodeText
                $GeneralAvailabilityText = $Cells[3] | Get-HtmlNodeText
                [nullable[datetime]]$PublicPreview = $null
                [nullable[datetime]]$GeneralAvailability = $null

                $Dummy = [DateTime]::MinValue
                if ([DateTime]::TryParseExact($PublicPreviewText, 'MMM d, yyyy', $EnUsCulture, [System.Globalization.DateTimeStyles]::None, [ref]$Dummy))
                {
                    $PublicPreview = $Dummy
                }

                $Dummy = [DateTime]::MinValue
                if ([DateTime]::TryParseExact($GeneralAvailabilityText, 'MMM d, yyyy', $EnUsCulture, [System.Globalization.DateTimeStyles]::None, [ref]$Dummy))
                {
                    $GeneralAvailability = $Dummy
                }

                [PSCustomObject]@{
                    PSTypeName              = 'UncommonSense.BcUtils.BcReleaseWaveFeature'
                    Wave                    = $Wave
                    Section                 = $Section
                    Feature                 = $Feature
                    EnabledFor              = $EnabledFor
                    PublicPreviewText       = $PublicPreviewText
                    GeneralAvailabilityText = $GeneralAvailabilityText
                    PublicPreview           = $PublicPreview
                    GeneralAvailability     = $GeneralAvailability
                }
            }
        }
    }
}


Get-BcReleaseWaveFeature -Wave 2024wave1
Get-BcReleaseWaveFeature -Wave 2021wave1