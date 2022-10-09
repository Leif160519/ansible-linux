if [ -x "$(command -v fzf)"  ]
then
    if [ -f /usr/share/doc/fzf/examples/completion.bash ]
    then
        source /usr/share/doc/fzf/examples/completion.bash
    fi

    if [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]
    then
        source /usr/share/doc/fzf/examples/key-bindings.bash
    fi
fi
