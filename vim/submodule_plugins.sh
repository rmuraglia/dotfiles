# set up the git submodules for the plugins
# note: by default the version of bash shipped with osx is too old to have this associative array syntax -- just do a `brew install bash` to get a more modern version

plugin_path='pack/plugins/start'

declare -A plugins=(
    # plugin_name :: git clone URL
    ['lightline']='https://github.com/itchyny/lightline.vim.git'
    ['gitbranch']='https://github.com/itchyny/vim-gitbranch.git'
    ['gitgutter']='https://github.com/airblade/vim-gitgutter.git'
    ['vim-cool']='https://github.com/romainl/vim-cool.git'
    ['indent-guides']='https://github.com/preservim/vim-indent-guides.git'
    ['better-whitespace']='https://github.com/ntpeters/vim-better-whitespace.git'
)

for plug in "${!plugins[@]}"; do
    git submodule add ${plugins[$plug]} ${plugin_path}/${plug}
done
