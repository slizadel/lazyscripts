#!/bin/bash
## mod_rpaf Lazy Script
## Author: David Wittman <david@wittman.com>

# Set configuration path (relative to default Apache directory)
CONFIGFILE="conf.d/mod_rpaf.conf"
TEMPDIR="/tmp"

bold=$(tput bold)
normal=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)

begin() {
        OUTPUT="$*"
        printf "${OUTPUT}"
}

pass() {
    COLUMNS=$(tput cols)
    echo $1 | awk -v width=${COLUMNS} '{ padding=(width-length($0)-8); printf "%"(padding)"s", "[  ";}'
    echo -e "${green}OK${normal}  ]"
}

# Usage: /path/to/command || die "This shit didn't work"
die() {
    COLUMNS=$(tput cols)
    echo $1 | awk -v width=${COLUMNS} '{ padding=(width-length($0)-8); printf "%"(padding)"s", "[ ";}'
    echo -e "${bold}${red}FAIL${normal} ]"
    exit 1
}

get_distro() {
if [ "$distro" == "Ubuntu" ]; then
	EXT=".deb"
	APACHE="apache2"
elif [ "$distro" == "Redhat/CentOS" ]; then
	EXT=".rpm"
	APACHE="httpd"
else
    echo "Unable to detect distribution."
	exit 1
fi
}

reload_apache() {
	/etc/init.d/${APACHE} reload > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "${red}Error${normal} detected upon Apache reload. Moving config file to ${CONFIGFILE}.old"
		mv /etc/${APACHE}/${CONFIGFILE}{,.old}
		/etc/init.d/${APACHE} reload
		exit 1
	fi
}

guess_lb() {
	if [ ! -d /var/log/${APACHE} ]; then
		return
	fi
	LB_GUESS=$(awk '/^10\.18[23]\.[^\s]*/ { print $1; exit }' /var/log/${APACHE}/*access?log)
	LB_GUESS=${LB_GUESS:-""}
}

install_deps() {
        if [[ $distro == "Redhat/CentOS" ]]; then
                local INSTALL="/usr/bin/yum -qy install"
                local DEPS="httpd-devel git gcc"
        elif [[ $distro == "Ubuntu" ]]; then
                local INSTALL="/usr/bin/apt-get install -yq"
                local DEPS="build-essential apache2-threaded-dev yada"
        fi

        begin "Installing dependencies..."
        ${INSTALL} ${DEPS} > /dev/null || die "${OUTPUT}"
        pass "${OUTPUT}"
}


get_distro
echo "${bold}${distro}${normal} detected."
install_deps

guess_lb
read -p "Enter the load balancer's internal IP address: [${LB_GUESS}] " -e LBIP
# Set LBIP to default if empty
LBIP=${LBIP:-${LB_GUESS}}

# Download and install mod_rpaf
OUTPUT="Cloning mod_rpaf..."
printf "$OUTPUT"
git clone git://github.com/gnif/mod_rpaf.git /tmp/rpaf
pass "$OUTPUT"

# Install package
OUTPUT="Installing package..."
printf "$OUTPUT"
cd /tmp/rpaf
if [ "$distro" == "Ubuntu" ]; then
        dpkg-buildpackage -b
        dpkg -i ../libapache2-mod-rpaf*.deb
elif [ "$distro" == "Redhat/CentOS" ]; then
        make
        make install
fi
pass "$OUTPUT"

# Post-install stuff
OUTPUT="Creating configuration files..."
printf "$OUTPUT"
cat > /etc/${APACHE}/${CONFIGFILE} <<EOF
LoadModule        rpaf_module modules/mod_rpaf.so
<IfModule mod_rpaf.c>
	RPAF_Enable On
	RPAF_SetHostName On
	# RPAF_ProxyIPs:	
	#	List of load balancer/proxy IP addresses (space delimited) 
	RPAF_ProxyIPs 127.0.0.1 ${LBIP}
	# RPAFheader: 	
	#	Header from which to pull client IP, commonly X-Forwarded-For
	RPAF_Header X-Cluster-Client-Ip
</IfModule>
EOF
pass "$OUTPUT"

# Reload Apache
echo "Reloading Apache..."
reload_apache

echo
echo "Ding! Fries are done."

