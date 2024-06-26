Note that I don't use vi(m) for actual heavy duty work, but I use it to edit configs and make minor changes enough that I still want to have consistent dotfiles and quick set up across machines.  
Because of my fairly light usage, these settings are only lightly vetted.
For example, all of the indentation stuff is sort of a kitchen-sink approach and/or cobbled together from various sources -- no idea if it is actually sane or doing *exactly* what I want, but it is close enough to my desired behavior.

General usage:

- make edits to the `vimrc` file in here
- add submodules to the `submodule_plugins.sh` script and re-run it when you add something
    - nb: if you want to remove a submodule, run `git rm ${path_to_submodule}` then `git commit` the change
- run the `provision.sh` script from this directory on any new machine

Some useful resources and notes I referred to and cross-referenced while putting this together:

- [Idiomatic vimrc: guidlines for sculpting your own `.vimrc`](https://github.com/romainl/idiomatic-vimrc/tree/master)
    - choosing to use a `~/.vim/vimrc` instead of `~/.vimrc` for easier portability of the whole `vimfiles` directory
    - looking up help within vim as `:help option`. Note you can also look it up in a browser at [vimhelp](https://vimhelp.org/)
    - checking the value of an option with: `:set option?`
- apparent stock defaults: [source](https://github.com/vim/vim/blob/master/runtime/defaults.vim)
    - for example note that `set backspace=indent,eol,start` is commonly listed in starter `vimrc` files, but it is apparently already a default in here
- [Customizing Vim](https://learnbyexample.github.io/vim_reference/Customizing-Vim.html)
    - nice explanations of the anatomy of vimrc customizations with practical examples
- some sample `vimrc` files or recommended options: [1](https://github.com/amix/vimrc/blob/master/vimrcs/basic.vim), [2](https://gist.github.com/pthrasher/3933522), [3](https://www.shortcutfoo.com/blog/top-50-vim-configuration-options)
- for anything that requires choosing a color (e.g. the ruler color column), you can refer to [xterm 256 colors](https://www.ditig.com/publications/256-colors-cheat-sheet) to find the appropriate color codes
- the plugin ecosystem is vast, here are some directories of vim plugins: [1](https://vimawesome.com/), [2](https://github.com/akrawchyk/awesome-vim?tab=readme-ov-file), in general you can just search for "essential vim plugins" or something like that to bootstrap your search. Keeping in mind that vim only pinch hits for me, so having it fully tuned is overkill, here are some that I like nevertheless:
    - [lightline](https://github.com/itchyny/lightline.vim): a nicer status bar than the default
        - [airline](https://github.com/vim-airline/vim-airline) is a popular alternative, but I like lightline's relative minimalism
        - one thing I do like is getting the git branch in the status line, which we can get with [gitbranch](https://github.com/itchyny/vim-gitbranch)
    - [vim-cool](https://github.com/romainl/vim-cool):  disable search highlighting after done, no need to spam `:noh` anymore
    - [gitgutter](https://github.com/airblade/vim-gitgutter) to quickly see which lines have been modified
    - [auto-pairs](https://github.com/jiangmiao/auto-pairs) to automatically insert the matching closing pair for parens, brackets, etc
        - I ended up disabling this one because I felt like it could be overly aggressive, especially in deletion
    - [indent guides](https://github.com/preservim/vim-indent-guides): visual markers for indentation levels
    - [better whitespace](https://github.com/ntpeters/vim-better-whitespace) to highlight trailing whitespace characters
    - [fugitive](https://github.com/tpope/vim-fugitive) is a super popular way to get git integration but a) I'm not that hardcore about my vim usage, and b) I'm so accustomed to the ohmyzsh git aliases (e.g. `gst` instead of `git status`, that I'd rather do them as a shell comand, like `:!gst`, so overall I don't use this
        - note to get those ohmyzsh aliases working, I need to symlink my `.zshrc` to `.zshenv`, or otherwise reload that omz plugin (and yes, it had to be `.zshenv` -- `.zprofile` was not enough)
    - others I heard mentioned and sounded interesting but that I didn't look into much (usually decided I wasn't enough of a power user to warrant them)
        - nerd tree + nerdtree git plugin
        - vim multiple cursors
        - vim surround
        - endwise, vim closer (smarter auto matching for control flow or bracket pairs instead of auto-pairs)
        - vim slime as a repl
