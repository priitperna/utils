# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

apidoc()
{
	php artisan l5-swagger:generate
}

tinker()
{
	~/tinx.sh
}

copy-bashrc()
{
	docker cp ~/.bashrc $(docker ps |grep nginx|awk '{print $1}' | head -1):/var/www/.bashrc
	docker cp ~/.bashrc $(docker ps |grep nginx|awk '{print $1}' | head -1):/root/.bashrc
}

copy-bashrc-ci()
{
	docker cp ~/.bashrc $(docker ps |grep ci4|awk '{print $1}' | head -1):/var/www/.bashrc
	docker cp ~/.bashrc $(docker ps |grep ci4|awk '{print $1}' | head -1):/root/.bashrc
}

a()
{
	umask 000
	php artisan "$@"
}

s()
{
	umask 000
	php spark "$@"
}

carbro-prod()
{
	ssh 18.185.111.63
}

carbro-test()
{
	ssh 173.212.194.28 # contabo

	docker exec -ti $(docker ps |grep web|awk '{print $1}' | head -1) bash
}

casafy-test()
{
	ssh 18.231.186.177
	#ssh 15.228.59.22
}

casafy-prod()
{
	ssh 18.229.160.32
}
casafy-prod2()
{
	ssh 18.230.187.26
}

ss-test()
{
	ssh -t shopper-shadow.test.code-lab.it "bash"
	docker exec -ti $(docker ps |grep cl_shoppersh|awk '{print $1}' | head -1) bash
}

ss-prod()
{
	ssh 18.229.160.32
}

login()
{
	eval $(aws ecr get-login --no-include-email --region eu-west-1 --profile registry-ro)
}

fixpath()
{
	# SETX COMPOSE_CONVERT_WINDOWS_PATHS 1
	export COMPOSE_CONVERT_WINDOWS_PATHS=1
}

npmw()
{
	export NODE_OPTIONS=--max_old_space_size=4096
	npm run watch-poll
}

deploy-test()
{
	currentBranch=$(git rev-parse --abbrev-ref HEAD)
	git checkout test-server
	git pull
	git merge $currentBranch --no-edit
	git push
	git checkout $currentBranch
}

ide()
{
	php artisan ide-helper:generate
	php artisan ide-helper:models --write-mixin
	php artisan ide-helper:meta
}

cmod()
{
	usermod -u 1000 www-data
	chown -R 1000:1000 ./*
	chown -R www-data:www-data storage/logs
	chown -R www-data:www-data storage/logs/*
	chown -R www-data:www-data storage/framework/*
	chown -R www-data:www-data public/*
	chown www-data:www-data database/migrations
	chown -R www-data:www-data bootstrap/*
	chmod -R 777 .
	chmod -R 777 .idea
	chmod -R 777 .git
}

userm()
{
	usermod -u 1000 www-data
}


dl()
{
	case "${PWD##*/}" in

	  shopper-shadow-backend)
		docker-compose exec -w /app/myapp --user bitnami ci4 bash
		;;

	  Casafy | Carbro)
		docker-compose exec --user www-data nginx bash
		;;

	  *)
		echo -n "unknown project"
		;;
	esac
}

d-up()
{
	case "${PWD##*/}" in

	  shopper-shadow-backend)
		docker-compose up -d
		docker cp ~/.bashrc $(docker ps |grep ci4|awk '{print $1}' | head -1):/home/bitnami/.bashrc
		docker cp ~/.bashrc $(docker ps |grep ci4|awk '{print $1}' | head -1):/root/.bashrc
		;;

	  Casafy | Carbro)
		docker-compose up -d nginx redis
		docker cp ~/.bashrc $(docker ps |grep nginx|awk '{print $1}' | head -1):/var/www/.bashrc
		docker cp ~/.bashrc $(docker ps |grep nginx|awk '{print $1}' | head -1):/root/.bashrc
		;;

	  *)
		echo -n "unknown project"
		;;
	esac
}

log()
{
	now=$(date +'%Y-%m-%d')
	case "${PWD##*/}" in

	  shopper-shadow-backend)
		grc -c ~/.grc/.grc.conf tail -f writable/logs/log-${now}.log
		;;

	  Casafy | Carbro)
		grc -c ~/.grc/.grc.conf tail -f logs/other/laravel-${now}.log
		;;

	  *)
		echo -n "unknown project"
		;;
	esac

}