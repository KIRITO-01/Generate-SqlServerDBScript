<#
.Synopsis
Create script for the database object
.Description
Requires PSVersion 7 or more
Generate script file using command same using like sqlserver wizard
.Inputs
 None. You cannot pipe objects to the script
.outputs
None. This does not generate any output instead create file
.EXAMPLE
Generate-SqlServerDBScript.ps1 -ServerInstanceName .\SQLEXPRESS -SQLAuth -user sa -pass admin -Path E:\tempdb -useDatabase -GenerateLog -scriptDropAndCreate -SchemaAndData -DatabaseName test,dbname1
.Example
Generate-SqlServerDBScript.ps1 -ServerInstanceName .\SQLEXPRESS -SQLAuth -user sa -pass admin -Path E:\tempdb -useDatabase -GenerateLog -scriptDropAndCreate -SchemaAndData 
.Example
Generate-SqlServerDBScript.ps1 -ServerInstanceName .\SQLEXPRESS -WindowsAuth -Path E:\tempdb -useDatabase -GenerateLog -scriptDropAndCreate -SchemaAndData 
.Example
Generate-SqlServerDBScript.ps1 -ServerInstanceName .\SQLEXPRESS -WindowsAuth -scriptCreate -SchemaOnly 
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $false)]
    [System.String]
    $ServerInstanceName,
    [Parameter(Mandatory = $false, Position = 1, ValueFromPipeline = $false)]
    [System.Array]
    $DatabaseName,    
    [Parameter(Mandatory = $false, Position = 2, ValueFromPipeline = $false)]
    [System.String]
    $Path,    
    [switch]$SQLAuth,
    [string]$user,
    [string]$pass,
    [switch]$WindowsAuth,
    [switch]$GenerateLog,
    [switch]$useDatabase,

    [switch]$scriptCreate,
    [switch]$scriptDrop,
    [switch]$scriptDropAndCreate,

    [switch]$SchemaOnly,
    [switch]$DataOnly,
    [switch]$SchemaAndData
   
)

function ModuleCheck () {
    if (Get-Module -ListAvailable -Name dbatools) {
        Import-Module dbatools
    } 
    else {
        Write-Host "Installing Module..."
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
        Install-Module dbatools -AllowClobber -AcceptLicense -Confirm:$false -Repository PSGallery
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Untrusted
        Import-Module dbatools
        Write-Host "Module Installed"
    }
}
function InstanceCheck ($instanceName) {
    $instance = 'Microsoft.SqlServer.Management.Smo'
    $serverInstance = New-Object ("$instance.Server") $instanceName 
    if ($WindowsAuth.IsPresent -eq $false) {
        $serverInstance.ConnectionContext.LoginSecure = $false
        $serverInstance.ConnectionContext.Login = $user
        $serverInstance.ConnectionContext.Password = $pass
    }
    if (!$serverInstance.Product) {
        Write-Host "Invalid Instance Name"
        Exit
    }
    return $serverInstance
}
function DirectoryCheck ($directory) {
    $foldername = "DatabasesScript"
    $directory = ($directory -eq "" ? (Split-Path $MyInvocation.PSCommandPath -Parent) : $directory ) + "\" + $foldername
    if ( !(Test-Path $directory))
    { $null = new-item -type directory -name "$foldername" -path (Split-Path $directory -Parent) }   
    return $directory
}
function DirectoryDateCheck ($directory) {
    $directory = $directory + "\" + $date_
    if ( !(Test-Path $directory))
    { $null = new-item -type directory -name "$date_" -path (Split-Path $directory -Parent) }   
    return $directory
}
function GetScript {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string] $filename,
        [Parameter(Mandatory = $false)]
        [switch] $createdrop = $false,
        [Parameter(Mandatory = $false)]
        [switch]$CreateOrAlter = $false,
        [Parameter(Mandatory = $false)]
        [switch]$ScriptDrops = $false,
        [Parameter(Mandatory = $false)]
        [bool]$ScriptSchema = $true,
        [Parameter(Mandatory = $false)]
        [bool]$Triggers = $true,
        [Parameter(Mandatory = $false)]
        [switch]$ScriptData = $false,
        [Parameter(Mandatory = $false)]
        [switch]$ScriptForAlter = $false
    )
    
    begin {
        
    }
    
    process {
        $scripter = New-Object Microsoft.SqlServer.Management.Smo.Scripter
        $scripter.Server = $ServerInstanceName
        $dbCompatibilityLevel = New-Object Microsoft.SqlServer.Management.Smo.SqlServerVersion
        # Version100	3	
        # Version105	4	
        # Version110	5	
        # Version120	6	
        # Version130	7	
        # Version140	8	
        # Version150	9	
        # Version80	1	
        # Version90	2
        $dbCompatibilityLevel = 5  
        $scriptoptions = New-Object Microsoft.SqlServer.Management.Smo.ScriptingOptions
        $scriptoptions.AnsiPadding = $false
        $scriptoptions.AppendToFile = $false
        $scriptoptions.FileName = $filename        
        $scriptoptions.Encoding = New-Object System.Text.UnicodeEncoding      
        $scriptoptions.DriWithNoCheck = $false
        $scriptoptions.IncludeFullTextCatalogRootPath = $false
        $scriptoptions.SpatialIndexes = $false
        $scriptoptions.ColumnStoreIndexes = $false
        $scriptoptions.BatchSize = 1
        $scriptoptions.TargetServerVersion = $dbCompatibilityLevel       
        $scriptoptions.TargetDatabaseEngineType = "Standalone"
        $scriptoptions.TargetDatabaseEngineEdition = "Unknown"
        $scriptoptions.AnsiFile = $false
        $scriptoptions.ToFileOnly = $true
        $scriptoptions.SchemaQualify = $true
        $scriptoptions.IncludeHeaders = $true
        $scriptoptions.IncludeScriptingParametersHeader = $false
        $scriptoptions.IncludeIfNotExists = $false
        $scriptoptions.WithDependencies = $false
        $scriptoptions.DriPrimaryKey = $false
        $scriptoptions.DriForeignKeys = $false
        $scriptoptions.DriUniqueKeys = $false
        $scriptoptions.DriClustered = $false
        $scriptoptions.DriNonClustered = $false
        $scriptoptions.DriChecks = $false
        $scriptoptions.DriDefaults = $false
        $scriptoptions.Triggers = $Triggers
        $scriptoptions.Statistics = $false
        $scriptoptions.ClusteredIndexes = $true
        $scriptoptions.NonClusteredIndexes = $false
        $scriptoptions.NoAssemblies = $false
        $scriptoptions.PrimaryObject = $true
        $scriptoptions.Default = $true
        $scriptoptions.XmlIndexes = $false
        $scriptoptions.FullTextCatalogs = $false
        $scriptoptions.FullTextIndexes = $false
        $scriptoptions.FullTextStopLists = $false
        $scriptoptions.Indexes = $true
        $scriptoptions.DriIndexes = $false
        $scriptoptions.DriAllKeys = $true
        $scriptoptions.DriAllConstraints = $true
        $scriptoptions.DriAll = $true
        $scriptoptions.Bindings = $false
        $scriptoptions.NoFileGroup = $false
        $scriptoptions.NoFileStream = $false
        $scriptoptions.NoFileStreamColumn = $false
        $scriptoptions.NoCollation = $false
        $scriptoptions.ContinueScriptingOnError = $false
        $scriptoptions.IncludeDatabaseRoleMemberships = $false
        $scriptoptions.Permissions = $false
        $scriptoptions.AllowSystemObjects = $true
        $scriptoptions.NoIdentities = $false
        $scriptoptions.ConvertUserDefinedDataTypesToBaseType = $false
        $scriptoptions.TimestampToBinary = $false
        $scriptoptions.ExtendedProperties = $true
        $scriptoptions.DdlHeaderOnly = $false
        $scriptoptions.DdlBodyOnly = $false
        $scriptoptions.NoViewColumns = $false
        $scriptoptions.SchemaQualifyForeignKeysReferences = $false
        $scriptoptions.AgentAlertJob = $false
        $scriptoptions.AgentJobId = $true
        $scriptoptions.AgentNotify = $false
        $scriptoptions.LoginSid = $false
        $scriptoptions.NoCommandTerminator = $false
        $scriptoptions.NoIndexPartitioningSchemes = $false
        $scriptoptions.NoTablePartitioningSchemes = $false
        $scriptoptions.IncludeDatabaseContext = $false
        $scriptoptions.NoXmlNamespaces = $false
        $scriptoptions.DriIncludeSystemNames = $false
        $scriptoptions.OptimizerData = $true
        $scriptoptions.NoExecuteAs = $false
        $scriptoptions.EnforceScriptingOptions = $false
        $scriptoptions.NoMailProfileAccounts = $false
        $scriptoptions.NoMailProfilePrincipals = $false
        $scriptoptions.NoVardecimal = $true
        $scriptoptions.ChangeTracking = $false
        $scriptoptions.ScriptForCreateDrop = $createdrop
        $scriptoptions.ScriptForCreateOrAlter = $CreateOrAlter
        $scriptoptions.ScriptForAlter = $ScriptForAlter
        $scriptoptions.ScriptDataCompression = $true
        $scriptoptions.ScriptDrops = $ScriptDrops
        $scriptoptions.ScriptSchema = $ScriptSchema 
        $scriptoptions.ScriptData = $ScriptData
        $scriptoptions.ScriptBatchTerminator = $true
        $scriptoptions.ScriptOwner = $false
        $scripter.Options = $scriptoptions 
        return $scripter
    }
    
    end {
        
    }
}

Set-PSDebug -Strict
$date = Get-Date -f yyyyMMdd-HHmmsss
$date_ = $date.Substring(0, $date.IndexOf('-'))
ModuleCheck

if ($WindowsAuth.IsPresent -eq $false -and $SQLAuth.IsPresent -eq $false) {
    Write-Error "Specify -WindowsAuth | -SQLAuth -user username -pass password"
    exit
}

if ($WindowsAuth.IsPresent -eq $true -and $SQLAuth.IsPresent -eq $true) {
    Write-Error "Can't use WindowsAuth and SQLAuth together"
    exit
}
if ($SQLAuth.IsPresent -eq $true ) {
    if ($user -eq "") {
        Write-Error "user not set  use -user username"
        exit
    }
    if ($pass -eq "") {
        Write-Error "password not set  use -pass password"
        exit
    }
}

$serverInstance = InstanceCheck $ServerInstanceName

$Path = DirectoryCheck $Path
$Path = DirectoryDateCheck $Path

$ExcludeDatabase = @("master", "model", "msdb", "tempdb")
$ExcludeSchemas = @("sys", "Information_Schema")
$IncludeTypes = @("Tables", "UserDefinedFunctions", "StoredProcedures", "Views", "Triggers") #object you want do backup. 

if ($GenerateLog.IsPresent -eq $true) {
    $logpath = Split-Path (Split-Path $Path -Parent ) -Parent
    $logpath += "\ScriptLog.txt"
}

if ($logpath) {
    if (!(Test-Path $logpath)) {
        $null = New-Item $logpath
    }
}


if ($scriptDrop -eq $false -and $scriptCreate -eq $false -and $scriptDropAndCreate -eq $false) {
    Write-Error "Specify Flag [scriptDrop | scriptCreate |scriptDropAndCreate]"
    exit
}
if ($SchemaOnly -eq $false -and $DataOnly -eq $false -and $SchemaAndData -eq $false) {
    Write-Error "Specify Flag [SchemaOnly | DataOnly |SchemaAndData]"
    exit
}
if ((@($scriptDrop, $scriptDropAndCreate, $scriptCreate) | Where-Object { $_ }).Length -gt 1) {
    Write-Error "Specify only one Flag [scriptDrop | scriptCreate |scriptDropAndCreate]"
    exit
}

if ((@($SchemaOnly, $DataOnly, $SchemaAndData) | Where-Object { $_ }).Length -gt 1) {
    Write-Error "Specify only one Flag [SchemaOnly | DataOnly |SchemaAndData]"
    exit
}


if ($DatabaseName) {
    $databases = $serverInstance.Databases | Where-Object -Property Name -NotIn $ExcludeDatabase  |  Where-Object -Property Name -In $DatabaseName.Split(',') 
    if (!$databases) {
        Write-Error "Invalid DatabaseName"
        exit
    }
    $tempDb = $DatabaseName | Where-Object { $_ -in $ExcludeDatabase }
    if ($tempDb) {
        Write-Error "Can not contain $tempDb Database"
        exit
    }
}
else {
    $databases = $serverInstance.Databases | Where-Object -Property Name -NotIn $ExcludeDatabase      
}
$null = $databases | ForEach-Object { $temppath = $Path + "\" + $_.Name ; if (!(Test-Path $temppath)) { new-item -type directory -name $_.Name -path (Split-Path $temppath -Parent) } } 
$scriptype = if ($scriptCreate.IsPresent) { "Create" }elseif ($scriptDrop.IsPresent) { "Drop" }elseif ($scriptDropAndCreate.IsPresent) { "DropandCreate" }
$scriptype += "-"
$scriptype += if ($SchemaOnly.IsPresent) { "Schema" }elseif ($SchemaAndData.IsPresent) { "SchemaandData" }elseif ($DataOnly.IsPresent) { "Data" }

[datetime]$starttime = Get-Date
Write-Output "Exporting ..."
if ($logpath) {   
    "`n#### Generating Script for $($scriptype) on  $(Get-Date)  ####" | Add-Content $logpath
    "--Started Exporting on $(Get-Date $starttime -Format HH:mm:ss )" | Add-Content $logpath
}


foreach ($db in $databases) {
    [datetime]$startdbtime = Get-Date 
    Write-Output  "`nExporting Database $($db.Name)" 
    if ($logpath) {        
        "`nExporting Database $($db.Name)" | Add-Content $logpath       
    }
    $temppath = $Path + "\" + $db.Name + "\" + $db.Name + "-$($scriptype)-BackupScript" + "$date" + ".sql"
    
    ##create schema
    if ($scriptCreate.IsPresent -eq $true -and $SchemaOnly.IsPresent -eq $true) {       
        if ($useDatabase.IsPresent) { "USE [master]`nGO" | Add-Content $temppath }
        $scripter = GetScript 
        $ss = $scripter.EnumScript($db)
        $ss | ForEach-Object { $AlterCOMPATIBILITY_LEVEL = ""; if ($_ -match "FULLTEXTSERVICEPROPERTY") { $AlterCOMPATIBILITY_LEVEL = "ALTER DATABASE [$($db.Name)] SET COMPATIBILITY_LEVEL = 110`nGO`n" } if ($_ -notmatch "READ_WRITE") { $AlterCOMPATIBILITY_LEVEL + $_ + "`nGO" }else { $AlterReadWrite = $_ } } | Add-Content $temppath
        if ($useDatabase.IsPresent) { "USE [$($db.Name)]`nGO" | Add-Content $temppath }
        $IncludeTypes | ForEach-Object { $db.$_ | ForEach-Object { if ($ExcludeSchemas -notcontains $_.Schema) { $scripter = GetScript; $ss = $scripter.EnumScript($_); $ss + "GO" | Add-Content $temppath } } } 
        $AlterReadWrite + "`nGO`n" |  Add-Content $temppath
    }
    ##drop schema
    if ($scriptDrop.IsPresent -eq $true -and $SchemaOnly.IsPresent -eq $true) {
        if ($useDatabase.IsPresent) { "USE [$($db.Name)]`nGO" | Add-Content $temppath }
        $IncludeTypes  | ForEach-Object { $db.$_ | ForEach-Object { if ($ExcludeSchemas -notcontains $_.Schema) { $scripter = GetScript -ScriptDrops:$true ; $ss = $scripter.EnumScript($_); $ss + "GO" | Add-Content $temppath } } } 
        if ($useDatabase.IsPresent) { "USE [master]`nGO" | Add-Content $temppath }
        $scripter = GetScript -ScriptDrops:$true 
        $ss = $scripter.EnumScript($db)    
        $ss + "GO`n" | Add-Content $temppath
    }
    ##dropandCreate schema
    if ($scriptDropAndCreate.IsPresent -eq $true -and $SchemaOnly.IsPresent -eq $true) {
        if ($useDatabase.IsPresent) { "USE [$($db.Name)]`nGO" | Add-Content $temppath }
        ForEach-Object { $db.Tables | ForEach-Object {  $_.Triggers | ForEach-Object {  $scripter = GetScript -ScriptDrops:$true ; $ss = $scripter.EnumScript($_); $ss | ForEach-Object { $_ + "`nGO" } | Add-Content $temppath } } } 
        $IncludeTypes  | ForEach-Object { $db.$_ | ForEach-Object { if ($ExcludeSchemas -notcontains $_.Schema) { $scripter = GetScript -ScriptDrops:$true ; $ss = $scripter.EnumScript($_); $ss + "GO" | Add-Content $temppath } } } 
        if ($useDatabase.IsPresent) { "USE [master]`nGO" | Add-Content $temppath }
        $scripter = GetScript -ScriptDrops:$true 
        $ss = $scripter.EnumScript($db)    
        $ss + "GO`n" | Add-Content $temppath
        $scripter = GetScript 
        $ss = $scripter.EnumScript($db)
        $ss | ForEach-Object { $AlterCOMPATIBILITY_LEVEL = ""; if ($_ -match "FULLTEXTSERVICEPROPERTY") { $AlterCOMPATIBILITY_LEVEL = "ALTER DATABASE [$($db.Name)] SET COMPATIBILITY_LEVEL = 110`nGO`n" } if ($_ -notmatch "READ_WRITE") { $AlterCOMPATIBILITY_LEVEL + $_ + "`nGO" }else { $AlterReadWrite = $_ } } | Add-Content $temppath
        if ($useDatabase.IsPresent) { "USE [$($db.Name)]`nGO" | Add-Content $temppath }
        $IncludeTypes | ForEach-Object { $db.$_ | ForEach-Object { if ($ExcludeSchemas -notcontains $_.Schema) { $scripter = GetScript -Triggers:$false; $ss = $scripter.EnumScript($_); $ss + "GO" | Add-Content $temppath } } } 
        ForEach-Object { $db.Tables | ForEach-Object {  $_.Triggers | ForEach-Object {  $scripter = GetScript ; $ss = $scripter.EnumScript($_); $ss | ForEach-Object { $_ + "`nGO" } | Add-Content $temppath } } } 
        if ($useDatabase.IsPresent) { "USE [master]`nGO" | Add-Content $temppath }
        $AlterReadWrite + "`nGO`n" |  Add-Content $temppath

    }
    ##create data
    if ($scriptCreate.IsPresent -eq $true -and $DataOnly.IsPresent -eq $true) {
        if ($useDatabase.IsPresent) { "USE [$($db.Name)]`nGO" | Add-Content $temppath }
        ForEach-Object { $db.Tables | ForEach-Object { if ($ExcludeSchemas -notcontains $_.Schema) { $scripter = GetScript -ScriptData:$true -ScriptSchema:$false; $ss = $scripter.EnumScript($_); $ss | ForEach-Object { $_ + "`nGO" } | Add-Content $temppath } } } 
    }
    ##drop data
    if ($scriptDrop.IsPresent -eq $true -and $DataOnly.IsPresent -eq $true) {
        if ($useDatabase.IsPresent) { "USE [$($db.Name)]`nGO" | Add-Content $temppath }
        $db.Tables | ForEach-Object { "DELETE FROM " + $_.ToString() + "`nGO" } | Add-Content $temppath 
    }
    ##dropandcreate data
    if ($scriptDropAndCreate.IsPresent -eq $true -and $DataOnly.IsPresent -eq $true) {
        if ($useDatabase.IsPresent) { "USE [$($db.Name)]`nGO" | Add-Content $temppath }
        $db.Tables | ForEach-Object { "DELETE FROM " + $_.ToString() + "`nGO" } | Add-Content $temppath 
        ForEach-Object { $db.Tables | ForEach-Object { if ($ExcludeSchemas -notcontains $_.Schema) { $scripter = GetScript -ScriptData:$true -ScriptSchema:$false; $ss = $scripter.EnumScript($_); $ss | ForEach-Object { $_ + "`nGO" } | Add-Content $temppath } } } 
    }

    ##create schemaanddata
    if ($scriptCreate.IsPresent -eq $true -and $SchemaAndData.IsPresent -eq $true) {
        if ($useDatabase.IsPresent) { "USE [master]`nGO" | Add-Content $temppath }
        $scripter = GetScript 
        $ss = $scripter.EnumScript($db)
        $ss | ForEach-Object { $AlterCOMPATIBILITY_LEVEL = ""; if ($_ -match "FULLTEXTSERVICEPROPERTY") { $AlterCOMPATIBILITY_LEVEL = "ALTER DATABASE [$($db.Name)] SET COMPATIBILITY_LEVEL = 110`nGO`n" } if ($_ -notmatch "READ_WRITE") { $AlterCOMPATIBILITY_LEVEL + $_ + "`nGO" }else { $AlterReadWrite = $_ } } | Add-Content $temppath
        if ($useDatabase.IsPresent) { "USE [$($db.Name)]`nGO" | Add-Content $temppath }
        $IncludeTypes | ForEach-Object { $db.$_ | ForEach-Object { if ($ExcludeSchemas -notcontains $_.Schema) { $scripter = GetScript -Triggers:$false; $ss = $scripter.EnumScript($_); $ss + "GO" | Add-Content $temppath } } } 
        ForEach-Object { $db.Tables | ForEach-Object { if ($ExcludeSchemas -notcontains $_.Schema) { $scripter = GetScript -ScriptData:$true -ScriptSchema:$false; $ss = $scripter.EnumScript($_); $ss | ForEach-Object { $_ + "`nGO" } | Add-Content $temppath } } } 
        ForEach-Object { $db.Tables | ForEach-Object {  $_.Triggers | ForEach-Object {  $scripter = GetScript ; $ss = $scripter.EnumScript($_); $ss | ForEach-Object { $_ + "`nGO" } | Add-Content $temppath } } } 
        if ($useDatabase.IsPresent) { "USE [master]`nGO" | Add-Content $temppath }
        $AlterReadWrite + "`nGO`n" |  Add-Content $temppath
    }
    ##drop schemaanddata
    if ($scriptDrop.IsPresent -eq $true -and $SchemaAndData.IsPresent -eq $true) {
        if ($useDatabase.IsPresent) { "USE [$($db.Name)]`nGO" | Add-Content $temppath }
        ForEach-Object { $db.Tables | ForEach-Object {  $_.Triggers | ForEach-Object {  $scripter = GetScript -ScriptDrops:$true ; $ss = $scripter.EnumScript($_); $ss | ForEach-Object { $_ + "`nGO" } | Add-Content $temppath } } } 
        $IncludeTypes  | ForEach-Object { $db.$_ | ForEach-Object { if ($ExcludeSchemas -notcontains $_.Schema) { $scripter = GetScript -ScriptDrops:$true ; $ss = $scripter.EnumScript($_); $ss + "GO" | Add-Content $temppath } } } 
        if ($useDatabase.IsPresent) { "USE [master]`nGO" | Add-Content $temppath }
        $scripter = GetScript -ScriptDrops:$true 
        $ss = $scripter.EnumScript($db)    
        $ss + "GO`n" | Add-Content $temppath
    }
    ##dropandcreate schemaanddata
    if ($scriptDropAndCreate.IsPresent -eq $true -and $SchemaAndData.IsPresent -eq $true) {
        if ($useDatabase.IsPresent) { "USE [$($db.Name)]`nGO" | Add-Content $temppath }
        ForEach-Object { $db.Tables | ForEach-Object {  $_.Triggers | ForEach-Object {  $scripter = GetScript -ScriptDrops:$true ; $ss = $scripter.EnumScript($_); $ss | ForEach-Object { $_ + "`nGO" } | Add-Content $temppath } } } 
        $IncludeTypes  | ForEach-Object { $db.$_ | ForEach-Object { if ($ExcludeSchemas -notcontains $_.Schema) { $scripter = GetScript -ScriptDrops:$true ; $ss = $scripter.EnumScript($_); $ss + "GO" | Add-Content $temppath } } } 
        if ($useDatabase.IsPresent) { "USE [master]`nGO" | Add-Content $temppath }
        $scripter = GetScript -ScriptDrops:$true 
        $ss = $scripter.EnumScript($db)    
        $ss + "GO`n" | Add-Content $temppath

        $scripter = GetScript 
        $ss = $scripter.EnumScript($db)
        $ss | ForEach-Object { $AlterCOMPATIBILITY_LEVEL = ""; if ($_ -match "FULLTEXTSERVICEPROPERTY") { $AlterCOMPATIBILITY_LEVEL = "ALTER DATABASE [$($db.Name)] SET COMPATIBILITY_LEVEL = 110`nGO`n" } if ($_ -notmatch "READ_WRITE") { $AlterCOMPATIBILITY_LEVEL + $_ + "`nGO" }else { $AlterReadWrite = $_ } } | Add-Content $temppath
        if ($useDatabase.IsPresent) { "USE [$($db.Name)]`nGO" | Add-Content $temppath }
        $IncludeTypes | ForEach-Object { $db.$_ | ForEach-Object { if ($ExcludeSchemas -notcontains $_.Schema) { $scripter = GetScript -Triggers:$false ; $ss = $scripter.EnumScript($_); $ss + "GO" | Add-Content $temppath } } } 

        ForEach-Object { $db.Tables | ForEach-Object { if ($ExcludeSchemas -notcontains $_.Schema) { $scripter = GetScript -ScriptData:$true -ScriptSchema:$false; $ss = $scripter.EnumScript($_); $ss | ForEach-Object { $_ + "`nGO" } | Add-Content $temppath } } }         
        ForEach-Object { $db.Tables | ForEach-Object {  $_.Triggers | ForEach-Object {  $scripter = GetScript ; $ss = $scripter.EnumScript($_); $ss | ForEach-Object { $_ + "`nGO" } | Add-Content $temppath } } } 
        if ($useDatabase.IsPresent) { "USE [master]`nGO" | Add-Content $temppath }
        $AlterReadWrite + "`nGO`n" |  Add-Content $temppath
    }   

    [datetime]$enddbtime = Get-Date
    $completiondbtime = New-TimeSpan -Start $startdbtime -End $enddbtime  
    Write-Output  "$($db.Name) Exported timetaken $($(if($completiondbtime.Days -gt 0){$($completiondbtime.Days).ToString() +" Days"} if($completiondbtime.Hours -gt 0){$($completiondbtime.Hours).ToString() +" Hours"} if($completiondbtime.Minutes -gt 0){$($completiondbtime.Minutes).ToString() +" Minutes"} if($completiondbtime.Milliseconds -gt 0){$($completiondbtime.Milliseconds).ToString() +" Milliseconds"}) )"
    if ($logpath) {        
        "$($db.Name) Exported timetaken $($(if($completiondbtime.Days -gt 0){$($completiondbtime.Days).ToString() +" Days"} if($completiondbtime.Hours -gt 0){$($completiondbtime.Hours).ToString() +" Hours"} if($completiondbtime.Minutes -gt 0){$($completiondbtime.Minutes).ToString() +" Minutes"} if($completiondbtime.Seconds -gt 0){$($completiondbtime.Seconds).ToString() +" Seconds"} if($completiondbtime.Milliseconds -gt 0){$($completiondbtime.Milliseconds).ToString() +" Milliseconds"}) )" | Add-Content $logpath
    }

}
[datetime]$endtime = Get-Date
$completiontime = New-TimeSpan -Start $starttime -End $endtime

Write-Output  "`nExporting Complete on $(Get-Date $endtime -Format HH:mm:ss ) "
Write-Output "CompletionTime $(if($completiontime.Days -gt 0){$($completiontime.Days).ToString() +" Days"} if($completiontime.Hours -gt 0){$($completiontime.Hours).ToString() +" Hours"} if($completiontime.Minutes -gt 0){$($completiontime.Minutes).ToString() +" Minutes"} if($completiontime.Milliseconds -gt 0){$($completiontime.Milliseconds).ToString() +" Milliseconds"}) "
if ($logpath) {   
    "`n--Exporting Complete on $(Get-Date $endtime -Format HH:mm:ss ) " | Add-Content $logpath
    "--CompletionTime $(if($completiontime.Days -gt 0){$($completiontime.Days).ToString() +" Days"} if($completiontime.Hours -gt 0){$($completiontime.Hours).ToString() +" Hours"} if($completiontime.Minutes -gt 0){$($completiontime.Minutes).ToString() +" Minutes"} if($completiontime.Seconds -gt 0){$($completiontime.Seconds).ToString() +" Seconds"} if($completiontime.Milliseconds -gt 0){$($completiontime.Milliseconds).ToString() +" Milliseconds"}) " | Add-Content $logpath
}
exit
