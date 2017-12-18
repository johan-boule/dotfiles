# executed when the login option is on
#
# well-written explanation: http://mywiki.wooledge.org/DotFiles

bohan_prepend_path() { # env_var path
	local env_var=$1 &&
	local path=$2 &&
	if test -d $path
	then
		local old=$(eval echo \$$env_var) &&
		if test -n "$old"
		then
			export $env_var=$path:$old
		else
			export $env_var=$path
		fi
	fi
}

bohan_prepend_path PATH ~/local/bin
bohan_prepend_path PATH ~/local/games
bohan_prepend_path LD_LIBRARY_PATH ~/local/lib
bohan_prepend_path LIBRARY_PATH ~/local/lib
bohan_prepend_path CPATH ~/local/include
bohan_prepend_path PKG_CONFIG_PATH ~/local/lib/pkgconfig
bohan_prepend_path INFOPATH ~/local/share/info
# Note: We must not set MANPATH, because it masks system-wide paths (see the manpath command).
# Note: This is not a problem because man-db is clever enough to infer the man paths from the PATH env var.
#bohan_prepend_path MANPATH ~/local/share/man

tty -s && mesg y

# [bohan] if pam_mail.so doesn't set it
# [bohan] disabled on asteroid because that host forwards everything to factoid via nullmailer
#export MAIL=~/Maildir

# [bohan] bashrc files are not sourced on login interactive shells, which is a stupid bash bug imo.
# Distributions work around this by sourcing /etc/bash.bashrc from /etc/profile when interactive,
# but they don't source ~/.bashrc there, and instead fixed that in /etc/skel/.profile
# This is imo quite ugly to require every user to have a correct ~/.profile.
# Bash should really be fixed to have a consistent way of sourcing bashrc files.
# Copied from /etc/skel/.profile:
# if running bash
if [ -n "$BASH_VERSION" ]; then
	# include .bashrc if it exists
	if [ -f "$HOME/.bashrc" ]; then
		. "$HOME/.bashrc"
	fi
fi
