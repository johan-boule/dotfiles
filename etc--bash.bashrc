# executed by bash when the interactive option is on, but                 
# this should be explicitely executed by /etc/profile for bash shells
# when both the login and interactive options are on.
#
# well-written explanation: http://mywiki.wooledge.org/DotFiles


# If the shell is not interactive, don't do anything.
case $- in
	*i*) ;;
	*) return;;
esac


##################
# bash completion

# Note: Currently, on Debian/Ubuntu, the completion is not sourced in bashrc.
# Note: The is actually a bug since it *is* sourced in /etc/profile.d/bash_completion.sh for login shells.
# Note: So it's inconsistent: login shells get completion, while non-login ones don't!
# Note: I call the profile.d script even if it's already been called in case of a login shell,  
# Note: but it's ok to call it several times because that script checks if completion has already been sourced.
. /etc/profile.d/bash_completion.sh 

##############
# window size

shopt -s checkwinsize # check the window size after each command and, if necessary, update the values of LINES and COLUMNS.


##########
# history

export HISTCONTROL=ignoreboth # don't put duplicate lines or lines starting with space in the history.
export HISTSIZE=10000
#unset HISTFILESIZE # unsetting does not work in startup script because it then gets defined later to the same value as HISTSIZE by default.
export HISTFILESIZE=1000000000
shopt -s histappend # append to the history file, don't overwrite it
shopt -s cmdhist # attempts to save all lines of a multiple-line command in the same history entry 
shopt -s lithist # multi-line commands are saved to the history with embedded newlines rather than using semicolon separators where possible
shopt -s globstar # supports recursive globbing with ** in pathname expansion
shopt -u direxpand # annoying. disabled. when enabled it expands variables when doing autocompletion 


#######
# misc

shopt -s autocd # a command name that is the name of a directory is executed as if it were the argument to the cd command
shopt -s checkjobs # lists the status of any stopped and running jobs before exiting an interactive shell


#####################
# ls and tree colors	

eval $(dircolors --bourne-shell) # enable color support of ls and tree


##########
# aliases

alias lsa='command ls --color=auto --indicator-style=classify --ignore-backups'
alias ls='lsa --almost-all'
alias lla='lsa --format=long --human-readable'
alias ll='lla --almost-all'

alias treea='command tree -AF' # -I *~
alias treefia='treea -fi'
alias tree='treea -a'
alias treefi='treefia -a'
alias dir='tree -pugilasDAFL 1' # useless; kept for curiousity

alias grep='grep --color=auto --exclude-dir=.git --exclude-dir=.svn --exclude="*~"' #--with-filename --line-number' (breaks bash completion)

alias diff=colordiff

alias rm='rm --interactive --preserve-root'
alias cp='cp --interactive'
alias mv='mv --interactive'
alias ln='ln --interactive'

alias j=jobs


########
# pompt

# set variable identifying the chroot you work in (used in the prompt below)
if test -z "$debian_chroot" && test -r /etc/debian_chroot
then
	debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, overwrite the one in /etc/profile)
PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '

case "$TERM" in
	xterm*|rxvt*)
		ps_color="\e[1m"
		ps_color_user="${ps_color}"
		ps_color_host="${ps_color}"
		ps_color_dir="\e[0m \e[1;34m"
		# set the title of the terminal window. (note that it overwrites command options like xterm -T "title" -n "icontitle")
		PROMPT_COMMAND='echo -ne "\e]0;${LOGNAME}@${HOSTNAME}:${PWD}\a"'
	;;
	linux)
		ps_color="\e[1m"
		ps_color_user="${ps_color}"
		ps_color_host="${ps_color}"
		ps_color_dir="\e[0m \e[1;34m"
	;;
	dumb)
		ps_color=""
		ps_color_user=""
		ps_color_host=""
		ps_color_dir=" "
	;;
	*)
		ps_color="\e[1m"
		ps_color_user="${ps_color}"
		ps_color_host="${ps_color}"
		ps_color_dir="\e[0m \e[1;34m"
	;;
esac
ps="\s \W"
if test $(id --user) -eq 0
then
	ps_color_user_id_0="\e[1;31m"
	user="${ps_color_user_id_0}${USER}\e[0m${ps_color_user}"
	if test "$(echo $SU_STACK | sed 's/.*->//')" != "$user"
	then
		export SU_STACK="${SU_STACK:+${SU_STACK}->}${user}"
	fi
	#ps="\s${ps_color_id_0}%\e[0m "
	ps="${ps}%"
	unset user ps_color_user_id_0
else
	if test "$(echo $SU_STACK | sed 's/.*->//')" != $USER
	then
		export SU_STACK="${SU_STACK:+${SU_STACK}->}${USER}"
	fi
	#ps="\s\e[1m#\e[0m "
	ps="${ps}#"
fi
ps="$ps "
if false # don't display groups (disabled on steroid because there are many)
then
	for i in $(groups)
	do
		if test ! "$i" = "$USER"
		then
			groups="${groups:+$groups+}$i"
		fi
	done
	if test $groups
	then
		groups="($groups)"
	fi
else
	groups=''
fi
PS1="${ps_color_user}${SU_STACK}${groups}${ps_color_host}@$(hostname --fqdn):\l \j \A${ps_color_dir}\w" &&
PS1="${PS1}\$(test \$? -eq 0 || echo -e ' \033[1;31m\007(command failed)')" &&
PS1="${PS1}\033[0m\n$ps" &&
unset ps ps_color ps_color_user ps_color_host ps_color_dir groups


#######
# bell
# note: it's not nice, when logging in to a server, this affects the *client* machine!

if test -n "$DISPLAY"
then
	# setterm reads terminfo and it seems it doesn't always work for all X terminals.
	# we can use xset instead, which is a global, non per-terminal setting for the X server.
	# better done in X init scripts
	xset b 40 32 10 # vol freq dur
else
	setterm -bfreq 21 -blength 25
fi


################
# keyboard rate
# note: it's not nice since these are global, non per-terminal settings.

case "$TERM" in
	linux)
		# need to be root, better done in /etc/console-tools/config
		#kbdrate -s -d 200 -r 60
	;;
	*)
		# better done in X init scripts
		# note: it's not nice, when logging in to a server, this affects the *client* machine!
		#test -n "$DISPLAY" && xset r rate 200 60
	;;
esac


################
# keyboard leds

if test -n "$DISPLAY"
then
	xset led 3
else
	# better done in /etc/console-tools/config
	#setleds +num +scroll
	:
fi
