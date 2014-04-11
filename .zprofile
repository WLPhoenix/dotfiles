echo "Running .zprofile"

# if running zsh
# include .zshrc if it exists
if [ -f "$HOME/.zshrc" ]; then
    source "$HOME/.zshrc"
fi

