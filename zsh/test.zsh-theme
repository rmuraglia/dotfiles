autoload -Uz vcs_info
autoload -U add-zsh-hook
autoload -U colors && colors
setopt prompt_subst
add-zsh-hook precmd build_prompt

newline=$'\n'

# colors
# TODO: currently using a mix of two zsh color methods: https://unix.stackexchange.com/q/579773
# would be nice to standardize on one
success_color=$fg_bold[green]
fail_color=$fg_bold[red]
path_color=$fg_bold[cyan]
python_fg='%F{yellow}'
python_bg='%K{021}'  # a darker blue
github_bg='%K{237}'  # dark gray

# unicode marks
success_mark=$(printf '\u25cf')  # ●
fail_mark=$(printf '\u2716')  # ✖
arrowhead_mark=$(printf '\u2514\u2500\u2500\u27a4')  # └──➤
github_mark=$(printf '\uf09b')  #   -- for some reason trying to sub this in later doesn't work, so I just use the glyph directly in the vcs info style below
python_mark=$(printf '\uf3e2')  # 

# version control display
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '⁺'
zstyle ':vcs_info:*' formats '  %u %r::%b ' '%S'
zstyle ':vcs_info:*' nvcsformats '' '%~'

build_prompt() {
    vcs_info
    # use single quotes when defining the components of the prompt, so none of the variables are not expanded
    # we will expand them all at once together when assembling the prompt
    last_exit_status='%(?:%{${success_color}%}${success_mark}:%{${fail_color}%}${fail_mark})'
    path_chunk='%{${path_color}%}${vcs_info_msg_1_}'
    set_exit_color='%(?:%{${success_color}%}:%{${fail_color}%})'

    # for the pyenv virtualenv indicator, only display it if we are *not* in the global env
    pyenv_active=$(pyenv version-name)
    pyenv_global=$(pyenv global)
    if [ ${pyenv_active} != ${pyenv_global} ]; then
        pyenv_chunk='${python_bg}${python_fg} ${python_mark} ${pyenv_active} %{$reset_color%}'
    else
        pyenv_chunk=''
    fi

    # colorize the github repo/branch indicator
    github_chunk='${github_bg}${vcs_info_msg_0_}%{$reset_color%}'

    PROMPT="${last_exit_status} ${path_chunk}${newline}${set_exit_color}${arrowhead_mark} %{$reset_color%}"
    RPROMPT="${github_chunk}${pyenv_chunk}"
}
