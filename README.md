# Generate-SqlServerDBScript

<b>Synopsis</b><br>
Create script for the database object<br><br>
 <b>Description</b><br>
Requires PSVersion 7 or more
Generate script file using command same using like sqlserver wizard<br><br>
<b>Inputs</b><br>
 None. You cannot pipe objects to the script<br><br>
<b>outputs</b><br>
None. This does not generate any output instead create file<br><br>
<b>EXAMPLE 1</b><br>
Generate-SqlServerDBScript.ps1 -ServerInstanceName .\SQLEXPRESS -SQLAuth -user sa -pass admin -Path E:\tempdb -useDatabase -GenerateLog -scriptDropAndCreate -SchemaAndData -DatabaseName test,dbname1<br><br>
<b>EXAMPLE 2</b><br>
Generate-SqlServerDBScript.ps1 -ServerInstanceName .\SQLEXPRESS -SQLAuth -user sa -pass admin -Path E:\tempdb -useDatabase -GenerateLog -scriptDropAndCreate -SchemaAndData <br><br>
<b>EXAMPLE 3</b><br>
Generate-SqlServerDBScript.ps1 -ServerInstanceName .\SQLEXPRESS -WindowsAuth -Path E:\tempdb -useDatabase -GenerateLog -scriptDropAndCreate -SchemaAndData <br><br>
<b>EXAMPLE 4</b><br>
Generate-SqlServerDBScript.ps1 -ServerInstanceName .\SQLEXPRESS -WindowsAuth -scriptCreate -SchemaOnly <br><br>

