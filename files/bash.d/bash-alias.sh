alias cp="/bin/cp -a"
alias rm="/bin/rm -I"
alias ll="/bin/ls --color=always -hFxtrl"
alias la="/bin/ls --color=always -hFXA"
##
# Is there any reason why you cannot use aliases whilst using sudo?
# https://askubuntu.com/questions/22037/aliases-not-available-when-using-sudo
##
alias sudo="sudo "
####

tcp() {
    tar cpf - ${(@)argv[1, -2]} | tar xvf - -C ${argv[-1]}
}

P() { # ps
    ps aux | grep -v "grep" | grep -B2 "$1"
}

N() { # netstat
    netstat -natlp | grep -v "grep" | grep "$1"
}

T() { # tail
    tail -F "$*"
}

W() { # wget
    wget -c $1 --no-check-certificate
}

F() { # find
    find $1 -type f | xargs grep $2 --color=always
}

# archive {{{
tgz() {
    name=$(echo $1 | /bin/sed 's/\/*$//g')
    tar -zcf "$name.tgz" $@
}
tgx() {
    tar -zxvf $@
}
tgg() {
    tar -tf $@
}

tjz() {
    name=$(echo $1 | /bin/sed 's/\/*$//g')
    tar -jcf "$name.tbz" $@
}
tjx() {
    tar -jxvf $@
}
tjj() {
    tar -tf $@
}
# }}}
