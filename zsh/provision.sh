# install fontawesome for terminal glyphs
brew tap homebrew/cask-fonts
brew install font-fontawesome

# install vivid for pretty ls colors
brew install vivid

# bring in my custom prompt to omz
ln -s $(readlink -f test.zsh-theme) ~/.oh-my-zsh/custom/themes/.
echo 'You should now change the ZSH_THEME in L15 of .zshrc to "test"'

# my zshrc stuff is mostly separated out from the omz generated template then sideloaded as custom additions
ln -s $(readlink -f zshrc) ~/.oh-my-zsh/custom/zshrc.zsh

# to enable omz git aliases in vim shell commands (e.g. :!gst)
# ln -s ~/.zshrc ~/.zshenv
