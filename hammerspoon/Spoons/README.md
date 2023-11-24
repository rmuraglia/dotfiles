# Setting up the emoji picker spoon

- clone his `Emojis.spoon` [directory](https://github.com/aldur/dotfiles/tree/master/osx/hammerspoon/Spoons/Emojis.spoon) to `~/.hammerspoon/Spoons/Emojis.spoon`
- load the spoon: `hs.loadSpoon('Emojis')`
- bind the command: `spoon.Emojis:bindHotkeys({toggle = {{"cmd", "alt"}, 'e'}})