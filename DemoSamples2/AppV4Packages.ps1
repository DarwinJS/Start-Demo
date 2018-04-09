Function Get-AppV4Packages {   
  Return Get-WmiObject Package -NameSpace root/microsoft/appvirt/client   
} 

Get-AppVPackageVersion ($NameOrGUID) {

  (Get-Appv4packages | Where-object {($_.PackageGUID -eq $Id) -or ($_.Name -eq $Id)} | sort-object version -descending | Select Version -First 1)[0].Version

}