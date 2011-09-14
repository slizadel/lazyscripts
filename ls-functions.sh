#!/bin/bash
# LazyScripts function handler

# help - Print LazyScripts usage information
# TODO: Adjust tabbing
function help() {
	colors
#	echo -e "---------------------------------------------------------------------------------------------"
	echo -e "usage:\t${brightyellow}lz <subcommand>${norm}"
	echo
	echo -e "    help\t\tThis help message."
	echo -e "    version\t\tDisplay the current LazyScripts version."
	echo -e "    info\t\tDisplay useful system information"
	echo -e "    bwprompt\t\tSwitch to a plain prompt."
	echo -e "    colorprompt\t\tSwitch to a fancy colorized prompt."
	echo -e "    bigfiles\t\tList the top 50 files based on disk usage."
	echo -e "    mytuner\t\tMySQL Tuning Primer"
	echo -e "    highio\t\tReports stats on processes in an uninterruptable sleep state."
	echo -e "    mylogin\t\tAuto login to MySQL"
	echo -e "    myengines\t\tList MySQL tables and their storage engine."
	echo -e "    myusers\t\tList MySQL users and grants."
	echo -e "    apcheck\t\tVerify apache max client settings and memory usage."
	echo -e "    apdocs\t\tPrints out Apache's DocumentRoots"
	echo -e "    approc\t\tShows the memory used by each Apache process"
	echo -e "    rblcheck\t\tServer Email Blacklist Check"
	echo -e "    cloudkick\t\tInstall the Cloudkick agent"
	echo -e "    vhost\t\tAdd an Apache virtual host"
	echo -e "    postfix\t\tSet up Postfix for relaying email"
	echo -e "    lsync\t\tInstall lsyncd and configure this server as a master$norm"
	echo -e "    wordpress\t\tInstall Wordpress on this server"
	echo -e "    drupal\t\tInstall Drupal 7 on this server"
	echo -e "    webmin\t\tInstall Webmin on this server"
	echo -e "    suphp\t\tReplaces mod_php with mod_suphp"
	echo -e "    concurchk\t\tShow concurrent connections"
	echo -e "    crtchk\t\tCheck SSL Cert/Key to make sure they match"
	echo -e "    rpaf\t\tInstall mod_rpaf to set correct client IP behind a proxy."
	echo -e "    pma\t\t\tInstalls phpMyAdmin."
	echo -e "    whatis\t\tOutput the script that would be run with a specific command."
	echo
#	echo -e "---------------------------------------------------------------------------------------------"
}

# Tests if given parameter is a function
function isFunction() {
        declare -F $1 &> /dev/null
        return $?
}

# Installs binary calculator for mysqltuner
# TODO: Convert to install anything
function install_bc() {
        if [[ $distro = "Redhat/CentOS" ]]; then
                if [ -z "`which bc 2>/dev/null`" ]; then
                yum -y -q install bc
        else
                echo "BC installed, proceeding"
                fi
        elif [ "${distro}" == "Ubuntu" ]; then
             if [ -z "`which bc 2>/dev/null`" ]; then
                apt-get -y -q install bc
            else
                echo "BC installed, proceeding"
             fi
        fi
}

# Resize console columns/rows
function _resize() {
	# TODO: Make install process distro agnostic, gracefully exit if install fails
	if [ -z $(which resize) ]; then
		if [ "${distro}" == "Redhat/CentOS" ]; then
			echo "Installing xterm"
        		yum -y install xterm
    		elif [ "${distro}" == "Ubuntu" ]; then
			echo "Installing xterm"
			apt-get -y install xterm
		fi
	fi
	echo "resizing xterm"
	resize

}

# apcheck - Run ApacheBuddy script
function apcheck() {
        if [ "${distro}" == "Redhat/CentOS" ]; then
            if [ -z "`which perl`" ]; then
                echo "Installing perl"
                yum -y install perl
                fi
        fi
            if [ "${distro}" == "Ubuntu" ]; then
                if [ -z "`which perl`" ]; then
                echo "Installing perl"
                apt-get -y install perl
            fi
        fi
        lz apachebuddy
}

# apdocs - Find Apache DocumentRoots
function apdocs() {
        if [[ "${distro}" == "Redhat/CentOS" ]]
                then
    httpd -S 2>&1|grep -v "^Warning:"|egrep "\/.*\/"|sed 's/.*(\(.*\):.*).*/\1/'|sort|uniq|xargs cat|grep -i DocumentRoot|egrep -v "^#"|awk '{print $2}'|sort|uniq
        elif [[ "${distro}" == "Ubuntu" ]]
                then
        apache2ctl -S 2>&1|grep -v "^Warning:"|egrep "\/.*\/"|sed 's/.*(\(.*\):.*).*/\1/'|sort|uniq|xargs cat|grep -i DocumentRoot|egrep -v "^#"|awk '{print $2}'|sort|uniq
else
        echo "Unsupported OS. You're on your own."
fi
}

# approc - Show memory used by Apache processes
function approc() {
if [ "${distro}" == "Redhat/CentOS" ]; then
        for pid in $(pgrep httpd); do
                echo $pid $(ps -p$pid -ouser|sed '1d') $(pmap -d $pid 2>/dev/null | awk '/private/{print $4}')|tr -d 'K'|awk '{printf "%s %s %s MB\n", $1, $2, $3/1024}'
        done
fi
if [[ "${distro}" == "Ubuntu" ]]; then
        for pid in $(pgrep apache2); do
                echo $pid $(ps -p$pid -ouser|sed '1d') $(pmap -d $pid 2>/dev/null | awk '/private/{print $4}')|tr -d 'K'|awk '{printf "%s %s %s MB\n", $1, $2, $3/1024}'
        done
fi
}

# bigfiles - List top 50 files based on disk space usage
function bigfiles() {
echo -e "[ls-scr] $brightyellow\b List the top 50 files based on disk usage. $norm"
find / -type f -printf "%s %h/%f\n" | sort -rn -k1 | head -n 50 | awk '{ print $1/1048576 "MB" " " $2}'
}

# cloudkick - Install CloudKick agent
function cloudkick() {
if [[ $distro = "Redhat/CentOS" ]]; then
        cat > /etc/yum.repos.d/cloudkick.repo << EOF
[cloudkick]
name=Cloudkick
baseurl=http://packages.cloudkick.com/redhat/x86_64
gpgcheck=0
EOF
        yum -y -q install cloudkick-agent
        chkconfig cloudkick-agent on
        echo -e "Please enter the login credentials and $blinkred\bstart the agent. $norm"
        cloudkick-config
elif [ "${distro}" == "Ubuntu" ]; then
        echo 'deb http://packages.cloudkick.com/ubuntu lucid main' > /etc/apt/sources.list.d/cloudkick.list
        curl http://packages.cloudkick.com/cloudkick.packages.key | apt-key add -
        apt-get -q update
        apt-get -y -q install cloudkick-agent
        echo -e "Please enter the login credentials and $blinkred\bstart the agent. $norm"
        cloudkick-config
else
        echo "Unsupported OS. See https://support.cloudkick.com/Category:Installing_Cloudkick"
        exit
fi
}

# colors - Defines available colors and makes them globally accessible
function colors() {
	black='\E[0;30m';
	red='\E[0;31m';
	green='\E[0;32m';
	yellow='\E[0;33m';
	blue='\E[0;34m';
	magenta='\E[0;35m';
	cyan='\E[0;36m';
	norm='\E[0m';
	gray='\E[1;30m';
	brightred='\E[1;31m';
	brightgreen='\E[1;32m';
	brightyellow='\E[1;33m';
	brightblue='\E[1;34m';
	brightmagenta='\E[1;35m';
	brightcyan='\E[1;36m';
	brightwhite='\E[1;37m';
	blinkred='\E[5;1;31m';
	blinkgreen='\E[5;1;32m';
	blinkorange='\E[5;1;33m';
	blinkblue='\E[5;1;34';
	blinkmagenta='\E[5;1;35m';
	blinkcyan='\E[5;1;36m';
	blinkwhite='\E[5;1;37m';
	alias ls='ls --color'
}

# concurchk - List concurrent connections from netstat
function concurchk() {
echo -e "[ls-scr] $brightyellow\b Concurrent connections listed by netstat in numerical order.$norm"

if [ -n "$1" ]; then
	netstat -an |grep -i tcp |grep -v "0.0.0.0" |grep -v "::" |awk '{print $4, $5}' |awk -F: '{print $2}' |awk '{print $2, $1}' |sort |uniq -c |sort -n |grep $1
else
	netstat -an |grep -i tcp |grep -v "0.0.0.0" |grep -v "::" |awk '{print $4, $5}' |awk -F: '{print $2}' |awk '{print $2, $1}' |sort |uniq -c |sort -n
fi
}

# cpchk - Check for the spawn of Satan (Control Panels)
function cpchk() {
# Check for Plesk
if [ -f /usr/local/psa/version ]; then
        hmpsaversion=$( cat /usr/local/psa/version )
        echo -e "${brightyellow}Plesk Detected: ${brightblue} ${hmpsaversion}. ${norm}\n"
# Check for cPanel
elif [ -d /usr/local/cpanel ]; then
        hmcpanversion=$( cat /usr/local/cpanel/version )
        echo -e "${brightyellow}cPanel Detected: ${brightblue} ${hmcpanversion}. ${norm}\n"
else
        echo -e "${brightred}No Control Panel Detected.${norm}"
fi
}

# crtcheck - Compare SSL certificate and key file
function crtchk() {
        cd $LZS_PREFIX
        read -p "Enter path to key [/path/to/server.key]: " key
        read -p "Enter path to certificate [/path/to/server.crt]: " cert
        CERT_CHECK=$( openssl rsa -in ${key} -modulus -noout | openssl md5 )
        KEY_CHECK=$( openssl x509 -in ${cert} -modulus -noout | openssl md5 )
        if [[ $CERT_CHECK == $KEY_CHECK ]]; then
                echo "Match!"
        else
                echo "No Match! *sad trombone*"
        fi
        cd - > /dev/null 2>&1
}

# highio - Find I/O hogs
function highio() {
        echo "Collecting stats on I/O bound processes for ~10 seconds..."
            n=0
            iofile=$(mktemp)
            m=$((10*10))
            while [[ $n -lt $m ]]; do
                ps ax | awk '$3 ~ /D/ { print $5 }'
                sleep 0.1
                n=$((n+=1))
            done > $iofile
            echo "Top I/O bound processes in the last ~10 seconds."
            sort $iofile | uniq -c | sort -nr | head -n30
}

# info - Print out a bunch of system information
# TODO: Replace OS finding with distro variable
function info() {
	echo -e "----- Operating System -----"
	if [ "${distro}" == "Redhat/CentOS" ]; then
        	cat /etc/redhat-release
    	elif [ "${distro}" == "Ubuntu" ]; then
            	lsb_release -d
	else
		echo "Could not detect distribution type."
	fi
	echo -e "----- Disk Utilization -----"
	df -l -h /
	echo -e "----- Memory Information -----"
	free -m
	echo -e "----- Network Interfaces -----"
	lz ip
	echo -e "----- Uptime / Who is Online -----"
	uptime ; who
}

# ip - Prints IPv4 addresses for all eth* interfaces
function ip() {
        /sbin/ifconfig | awk '/^eth/ { printf("%s\t",$1) } /inet addr:/ { gsub(/.*:/,"",$2); if ($2 !~ /^127/) print $2; }'
}

# myengines - List MySQL Engines
function myengines() {
        # MySQL login helper
         mysql_client=$( which mysql )
         if [ -x $mysql_client ]; then
           if [ -e /etc/psa/.psa.shadow ]; then
            echo -e "[ls-scr] $brightyellow \bUsing Plesk's admin login. $norm"
            $mysql_client -u admin -p`cat /etc/psa/.psa.shadow` -e 'select table_schema, table_name, engine from information_schema.tables;'
           else
            i
        if [ -e /root/.my.cnf ]; then
             echo -e "[ls-scr] $brightwhite \bFound a local $brightyellow \bmy.cnf $brightwhite \bin root's homedir, attempting to login without password prompt. $norm"
              $mysql_client -e 'select table_schema, table_name, engine from information_schema.tables;'
              if [ "$?" -ne "0" ]; then
                echo -e "[ls-scr] $brightred \bFailed! $norm \bprompting for MySQL root password.$norm"
              fi
            else
                echo -e "[ls-scr] $brightmagenta \bCould not auto-detect MySQL root password - prompting.$norm"
               $mysql_client -u root -p -e 'select table_schema, table_name, engine from information_schema.tables;'
              if [ "$?" -ne "0" ]; then
                echo -e "[ls-scr] $brightyellow \bMySQL authentication failed.$norm"
              fi
            fi
           fi
         else
           echo -e "[ls-scr] $brightred\bCould not locate MySQL client in path.$norm"
         fi
         return 0;
}

# mylogin - Not sure what this does yet
function mylogin() {
# MySQL login helper
 mysql_client=$( which mysql )
 if [ -x $mysql_client ]; then
   if [ -e /etc/psa/.psa.shadow ]; then
    echo -e "[ls-scr] $brightyellow \bUsing Plesk's admin login. $norm"
    mysql -u admin -p`cat /etc/psa/.psa.shadow`
   else
    i
if [ -e /root/.my.cnf ]; then
     echo -e "[ls-scr] $brightwhite \bFound a local $brightyellow \bmy.cnf $brightwhite \bin root's homedir, attempting to login without password prompt. $norm"
      $mysql_client
      if [ "$?" -ne "0" ]; then
        echo -e "[ls-scr] $brightred \bFailed! $norm \bprompting for MySQL root password.$norm"
      fi
    else
        echo -e "[ls-scr] $brightmagenta \bCould not auto-detect MySQL root password - prompting.$norm"
       $mysql_client -u root -p
      if [ "$?" -ne "0" ]; then
        echo -e "[ls-scr] $brightyellow \bMySQL authentication failed or program exited with error.$norm"
      fi
    fi
   fi
 else
   echo -e "[ls-scr] $brightred\bCould not locate MySQL client in path.$norm"
 fi
 return 0;
}

# mytuner - Run MySQL Tuning Primer
function mytuner() {
	# Install binary calculator dependency
	install_bc
	lz tuning-primer
}

# myusers - List MySQL users
function myusers() {
	mysql -e "SELECT User,Host from mysql.user;" && mysql -B -N -e "SELECT user, host FROM user" mysql | sed 's,\t,"@",g;s,^,show grants for ",g;s,$,";,g;' | mysql | sed 's,$,;,g'
}

# rblcheck - Check to see if this host is on an Email Blacklist
function rblcheck() {
        curl checkrbl.com
}

# version - Display version information
function version(){
	echo "LazyScripts version $LZS_VERSION"
}

# vhost - Create an Apache VirtualHost
function vhost() {
if [[ $1 != "" ]]; then
                domain=$1
        else
        read -p "Please enter a domain (no www): "      domain
fi
        if [[ $distro = "Redhat/CentOS" ]]; then
                cat > /etc/httpd/vhost.d/$domain.conf << EOF
<VirtualHost *:80>
	ServerName $domain
	ServerAlias www.$domain
	DocumentRoot /var/www/vhosts/$domain
	<Directory /var/www/vhosts/$domain>
		AllowOverride All
	</Directory>
	CustomLog logs/$domain-access_log common
	ErrorLog logs/$domain-error_log
</VirtualHost>
EOF
                mkdir -p /var/www/vhosts/$domain
                service httpd restart > /dev/null 2>&1
        elif [[ $distro = "Ubuntu" ]]; then
                cat > /etc/apache2/sites-available/$domain << EOF
<VirtualHost *:80>
	ServerName $domain
	ServerAlias www.$domain
	DocumentRoot /var/www/vhosts/$domain
	<Directory /var/www/vhosts/$domain>
		AllowOverride All
	</Directory>
	CustomLog /var/log/apache2/$domain-access_log common
	ErrorLog /var/log/apache2/$domain-error_log
</VirtualHost>
EOF
                mkdir -p /var/www/vhosts/$domain
                a2ensite $domain > /dev/null 2>&1
                service apache2 restart  > /dev/null 2>&1
        else
                echo "Unsupported OS"
fi
}

# whatis - What is this?
function whatis() { export -f $1; export -pf; export -fn $1; }

# login - Login function, ldo
function login() {
	_resize
	tset -s xterm
	clear
	colors
	info
	lz histsetup
	cpchk
	# Print the MOTD
	cat /etc/motd 2> /dev/null
	echo -e "LazyScripts Project Page - https://github.com/hhoover/lazyscripts"
}

# Main execution thread
if ( isFunction $1 ); then
        $1
else
        echo "Sub-command '${1}' not found."
        exit 1
fi


