# Generate-SqlServerDBScript
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
