Start-Process -FilePath iex.bat -WorkingDirectory .\Router -ArgumentList "--werl --sname Router1@localhost -S mix"    

Start-Sleep -s 1

Start-Process -FilePath iex.bat -WorkingDirectory .\Router -ArgumentList "--werl --sname Router2@localhost -S mix"    

Start-Sleep -s 1

Start-Process -FilePath iex.bat -WorkingDirectory .\Router -ArgumentList "--werl --sname Router3@localhost -S mix"    

Start-Sleep -s 10

Start-Process -FilePath iex.bat -WorkingDirectory .\Server -ArgumentList "--werl --sname Server1@localhost -S mix"

Start-Sleep -s 1

Start-Process -FilePath iex.bat -WorkingDirectory .\Server -ArgumentList "--werl --sname Server2@localhost -S mix"

Start-Sleep -s 1

Start-Process -FilePath iex.bat -WorkingDirectory .\Server -ArgumentList "--werl --sname Server3@localhost -S mix"

Start-Sleep -s 1

Start-Process -FilePath iex.bat -WorkingDirectory .\Server -ArgumentList "--werl --sname Server4@localhost -S mix"

Start-Sleep -s 1

Start-Process -FilePath iex.bat -WorkingDirectory .\Server -ArgumentList "--werl --sname Server5@localhost -S mix"

Start-Sleep -s 1

Start-Process -FilePath iex.bat -WorkingDirectory .\Server -ArgumentList "--werl --sname Server6@localhost -S mix"

Start-Sleep -s 1

Start-Process -FilePath iex.bat -WorkingDirectory .\Server -ArgumentList "--werl --sname Server7@localhost -S mix"

Start-Sleep -s 1

Start-Process -FilePath iex.bat -WorkingDirectory .\Server -ArgumentList "--werl --sname Server8@localhost -S mix"

Start-Sleep -s 1

Start-Process -FilePath iex.bat -WorkingDirectory .\Server -ArgumentList "--werl --sname Server9@localhost -S mix"

Start-Sleep -s 1

Start-Process -FilePath iex.bat -WorkingDirectory .\Server -ArgumentList "--werl --sname Server10@localhost -S mix"

Start-Sleep -s 1

Start-Process -FilePath iex.bat -WorkingDirectory .\Cliente -ArgumentList "--werl --sname usuario1 -S mix"

Start-Sleep -s 1

Start-Process -FilePath iex.bat -WorkingDirectory .\Cliente -ArgumentList "--werl --sname usuario2 -S mix" 

Start-Sleep -s 1

Start-Process -FilePath iex.bat -WorkingDirectory .\Cliente -ArgumentList "--werl --sname usuario3 -S mix"

Start-Sleep -s 1

Start-Process -FilePath iex.bat -WorkingDirectory .\Cliente -ArgumentList "--werl --sname usuario4 -S mix"

Start-Sleep -s 1

Start-Process -FilePath iex.bat -WorkingDirectory .\Cliente -ArgumentList "--werl --sname usuario5 -S mix"

Start-Sleep -s 1

Start-Process -FilePath iex.bat -WorkingDirectory .\Cliente -ArgumentList "--werl --sname usuario6 -S mix"

Start-Sleep -s 1

Start-Process -FilePath iex.bat -WorkingDirectory .\Cliente -ArgumentList "--werl --sname usuario7 -S mix"
