cd Router
$env:type = 'router'; iex.bat --werl --sname "router-1@localhost" -S mix
Start-Sleep -Milliseconds 5000
cd ..

cd Server
$env:type = 'server'; iex.bat --werl --sname server-1 -S mix
Start-Sleep -Milliseconds 5000
cd ..

cd Cliente
$env:type = 'client'; iex.bat --sname usuario1 --werl -S mix
Start-Sleep -Milliseconds 5000
$env:type = 'client'; iex.bat --sname usuario2 --werl -S mix
cd ..
