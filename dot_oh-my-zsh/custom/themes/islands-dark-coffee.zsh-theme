# Islands Relax Dark Coffee - Oh My Zsh Theme
# Based on the JetBrains Islands Relax Dark Coffee theme by Panxiaoan
#
# Color Reference:
#   mainBackground:    #3c3031
#   primaryBackground: #2C2122
#   accentColor:       #DBAB4A (gold)
#   underlineColor:    #A96F79 (muted rose)
#   lineColor:         #6E4552 (dark mauve)
#   primaryForeground: #BBBBBB
#   green:             #2fc864
#   red:               #ff5554
#   blue:              #5da3f4
#   yellow:            #f1fa8c
#   purple:            #bd93f9

# Git prompt configuration
ZSH_THEME_GIT_PROMPT_PREFIX="%{$FG[137]%}  %{$FG[174]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$FG[203]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$FG[078]%}✓"
ZSH_THEME_GIT_PROMPT_AHEAD=" %{$FG[137]%}⇡"
ZSH_THEME_GIT_PROMPT_BEHIND=" %{$FG[137]%}⇣"
ZSH_THEME_GIT_PROMPT_UNTRACKED=" %{$FG[137]%}?"
ZSH_THEME_GIT_PROMPT_STASHED=" %{$FG[141]%}⚑"

# Prompt components
local ret_status="%(?:%{$FG[078]%}❯:%{$FG[203]%}❯)"
local user_host="%{$FG[174]%}%n%{$FG[249]%}@%{$FG[174]%}%m"
local current_dir="%{$FG[137]%}%~"
local git_info='$(git_prompt_info)'
local timestamp="%{$FG[243]%}%T"

# Main prompt
#   user@host ~/path  branch ✓
#   ❯
PROMPT='
${user_host} ${current_dir}${git_info}
${ret_status}%{$reset_color%} '

# Right prompt: timestamp
RPROMPT='${timestamp}%{$reset_color%}'

# LS colors matching the theme palette
export LSCOLORS="gxfxcxdxbxegedabagacad"
export LS_COLORS="di=36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
