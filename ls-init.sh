#!/bin/bash
# LazyScripts Initializer Script
# https://github.com/hhoover/lazyscripts/
#
# Usage: dot (`. ls-init.sh`) or source this file (`source ls-init.sh`)
#        to load into your current shell
#

########################################################################
#   Functions which export a value to the shell must be in this file   #        
########################################################################

# Export LazyScript environment variables
export LZS_VERSION=007
# One-liner to get the script path, even if sourced
export LZS_PREFIX=$(dirname $(readlink -f $BASH_SOURCE))
export LZS_APP="$LZS_PREFIX/ls-functions.sh"
export LZS_URLPREFIX="git://github.com/hhoover/lazyscripts.git"
export LZS_GETURL="$LZS_URLPREFIX/ls-init.sh"
export LZS_MOD_PATH="${LZS_PREFIX}/modules/"

function isFunction() {
	declare -F $1 &> /dev/null
	return $?
}

# lz - Main function
function lz() {
        # Find files matching the parameter, limit 1
        local FILE=$(ls ${LZS_MOD_PATH}${1}.* 2> /dev/null | head -1)

        if [ $# -eq 1 ]; then
                if ( isFunction ${1} ); then
                        # Run the function
                        ${1}
                elif [ -r "${FILE}" ]; then
                        # Execute the module
                        chmod +x ${FILE} && ( ${FILE} )
                else   
                        # Try to run from ls-functions.sh
                        ( $LZS_APP ${1} )
                fi
        else   
                lz help
        fi
}

# bwprompt - A more simply b&w compatible shell prompt
function bwprompt() {
        export PS1="[\h \t]-(\w)# "
}

# colorprompt - Colorize PS1
function colorprompt() {
        local GRAY="\[\033[1;30m\]"
        local LIGHT_GRAY="\[\033[0;37m\]"
        local CYAN="\[\033[0;36m\]"
        local LIGHT_CYAN="\[\033[1;36m\]"
        local NORM="\[\033[0m\]"
        local LIGHT_BLUE="\[\033[1;34m\]"
        local YELLOW="\[\033[1;33m\]"
        local BLUE="\[\033[0;34m\]"
        local RED="\[\e[1;31m\]"
        local GREEN="\[\e[1;32m\]"
        local BROWN="\[\e[0;33m\]"
        if [ "${distro}" == "Redhat/CentOS" ]; then
                export PS1="$BLUE[$RED\000LZShell$LIGHT_BLUE \t$BLUE]$GRAY=$LIGHT_GRAY-$GRAY=$BLUE<$RED${distro}$BLUE>$GRAY=$LIGHT_GRAY-$GRAY=$BLUE($CYAN\u$GRAY @ $LIGHT_CYAN\H$BLUE)\n$BLUE($YELLOW\w$BLUE)$NORM # "
        elif [ "${distro}" == "Ubuntu" ]; then
                export PS1="$BLUE[$RED\000LZShell$LIGHT_BLUE \t$BLUE]$GRAY=$LIGHT_GRAY-$GRAY=$BLUE<$BROWN${distro}$BLUE>$GRAY=$LIGHT_GRAY-$GRAY=$BLUE($CYAN\u$GRAY @ $LIGHT_CYAN\H$BLUE)\n$BLUE($YELLOW\w$BLUE)$NORM # "
        else
                bwprompt
        fi  
}

# ostype - Determine Linux distribution
function ostype() {
    if [ -e /etc/redhat-release ]; then
        export distro="Redhat/CentOS"
    elif [ "$(lsb_release -d | awk '{print $2}')" == "Ubuntu" ]; then
        export distro="Ubuntu"
    else
        echo -e "Could not detect distribution type." && export distro="Other"
    fi
}


# lshelp - Backwards compatibility for existing autologin scripts
function lshelp {
        lz help
}

# lslogin - Backwards compatibility for existing autologin scripts
function lslogin {
	lz login
}

# Run these functions when loaded
ostype
colorprompt
# Export lz to subshells
export -f lz
