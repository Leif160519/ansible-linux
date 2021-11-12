shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"
export HISTTIMEFORMAT="%F %T "
