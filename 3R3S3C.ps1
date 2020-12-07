cd Router
iex.bat --werl --sname router-1@localhost --erl "-config config/router-1" -S mix
Start-Sleep -Milliseconds 5000
iex.bat --werl --sname router-2@localhost --erl "-config config/router-2" -S mix
Start-Sleep -Milliseconds 5000
iex.bat --werl --sname router-3@localhost --erl "-config config/router-3" -S mix
Start-Sleep -Milliseconds 5000
cd ..

cd Server
iex.bat --werl --sname server-1 -S mix
Start-Sleep -Milliseconds 5000
iex.bat --werl --sname server-2 -S mix
Start-Sleep -Milliseconds 5000
iex.bat --werl --sname server-3 -S mix
Start-Sleep -Milliseconds 5000
cd ..

cd Cliente
iex.bat --sname usuario1 --werl -S mix
Start-Sleep -Milliseconds 5000
iex.bat --sname usuario2 --werl -S mix
Start-Sleep -Milliseconds 5000
iex.bat --sname usuario3 --werl -S mix
Start-Sleep -Milliseconds 5000
cd ..
