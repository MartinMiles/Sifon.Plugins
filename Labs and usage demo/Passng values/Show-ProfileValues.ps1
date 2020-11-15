### Name: Show profile values
### Description: Demostrates how you can pass a single profile into a script a consume its values
### Compatibility: Sifon 0.98

param($Profile)

Add-Type -Path "c:\Sifon\Sifon.Abstractions.dll"
Add-Type -Path "c:\Sifon\Sifon.Code.dll"

# $Profile = [Sifon.Abstractions.Profiles.IProfile]$Profile
#$Profile = [Deserialized.Sifon.Code.Model.Profiles.Profile]$Profile

# $Profile | Get-Member | % { "${_.Name} = ${_.Value}" }
$Profile | Get-Member | % { $_.Name }

# ${Profile.AdminUsername}

# "Website: ${Profile.Website}"
# "Webroot : ${Profile.Webroot}"
# "Solr : ${Profile.Solr}"
