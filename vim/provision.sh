# symlink this to your home directory so vim can find it
ln -s $(readlink -f .) ~/.vim

# ensure that all submodules are pulled down for plugins
git submodule update --init --recursive
