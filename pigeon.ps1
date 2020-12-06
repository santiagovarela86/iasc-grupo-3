cd Router
$env:type = 'router'; iex.bat --werl --sname "router-1@localhost" -S mix
cd ..

cd Server
$env:type = 'server'; iex.bat --werl --sname server-1 -S mix
cd ..

cd Cliente
$env:type = 'client'; iex.bat --sname usuario1 --werl -S mix
$env:type = 'client'; iex.bat --sname usuario2 --werl -S mix
cd ..

exit
