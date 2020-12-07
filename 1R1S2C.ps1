cd Router
iex.bat --werl --sname "router-1@localhost" -S mix
Start-Sleep -Milliseconds 5000
cd ..

cd Server
iex.bat --werl --sname server-1 -S mix
Start-Sleep -Milliseconds 5000
cd ..

cd Cliente
iex.bat --sname usuario1 --werl -S mix
Start-Sleep -Milliseconds 5000
iex.bat --sname usuario2 --werl -S mix
cd ..
