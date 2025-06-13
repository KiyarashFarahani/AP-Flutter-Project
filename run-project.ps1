# Set paths
$libPath = "libs\gson-2.8.9.jar"
$outDir = "out"

# Create sources.txt with all .java files
Write-Host "`n📦 Gathering Java source files..."
Get-ChildItem -Recurse -Filter *.java | ForEach-Object { $_.FullName } > sources.txt

# Create output directory if it doesn't exist
if (!(Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir | Out-Null
}

# Compile
Write-Host "`n🛠️  Compiling Java files..."
javac -cp $libPath -d $outDir @sources.txt

if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ Compilation failed. Fix the errors above."
    exit 1
}

# Run the Server
Write-Host "`n🚀 Starting Server..."
Start-Process -NoNewWindow powershell -ArgumentList "-NoExit", "-Command", "java -cp 'out;$libPath' backend.Server.Server"

# Wait for server to start
Start-Sleep -Seconds 2

# Ask to run client
$runClient = Read-Host "`nDo you want to run the client too? (y/n)"
if ($runClient -eq "y") {
    Write-Host "`n📡 Running Client..."
    java -cp "out;$libPath" backend.client.Client}
else {
    Write-Host "`n🟢 Server is running. You can run the client manually if you want."
}
