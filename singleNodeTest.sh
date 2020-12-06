#!/usr/bin/env zsh
echo "IASC Program - Start"

# creates a new terminal window
function new() {
    open -a Terminal $1 
}

# Folders

projectFolder=$(pwd)
clientFolder=${projectFolder}/Cliente
routerFolder=${projectFolder}/Router
serverFolder=${projectFolder}/Server

# Alias

alias cdClient="cd ${clientFolder}"
alias cdRouter="cd ${routerFolder}"
alias cdServer="cd ${serverFolder}"
alias backToScriptFolder="cd ${projectFolder}"

# Process

# Ending Program
echo "IASC Program - End"
