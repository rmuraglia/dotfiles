# symlink this to your home directory so hammerspoon can find it
ln -s $(readlink -f .) ~/.hammerspoon

# ignore further changes to the secrets file: https://stackoverflow.com/a/43535767
git update-index --skip-worktree secrets.lua

# verify that homebrew is already installed: https://stackoverflow.com/a/20733281
# and pull the dependencies
if which brew 2> /dev/null; then
    brew install jq
    brew install blueutil
else
    echo "Homebrew doesn't appear to be installed. Please visit https://brew.sh/"
fi

# TODO: fetch and place the emojis spoon?
