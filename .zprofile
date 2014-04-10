echo "Running .zprofile"

# Setup variables and paths
if [ -f "$HOME/.mypaths" ]; then
    source "$HOME/.mypaths"
fi

# if running zsh
# include .zshrc if it exists
if [ -f "$HOME/.zshrc" ]; then
    source "$HOME/.zshrc"
fi

source $HOME/bin/on-startup.sh

