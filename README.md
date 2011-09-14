<h1>LazyScripts</h1>

<p>This is a set of bash shell functions to simplify and automate specific routine tasks, as well as some more specialized ones.</p>

<p>Compatibility - RHEL 5, CentOS 5, Ubuntu 10.04, Ubuntu 10.10</p>

<h3>How to use:</h3>
<p> Run this bash function as root:</p>
	function lsgethelper() { if [ -d /root/.lazyscripts ]; then cd /root/.lazyscripts/tools && git pull git://github.com/hhoover/lazyscripts.git; fi; cd ~ ; git clone git://github.com/hhoover/lazyscripts.git /root/.lazyscripts/tools; source /root/.lazyscripts/tools/ls-init.sh; }; lsgethelper && lslogin

<h3>Functions included:</h3>
<p>Execute by running: lz <i>function</i></p>
* info  - Display useful system information 
* bwprompt  - Switch to a plain prompt. 
* colorprompt  - Switch to a fancy colorized prompt. 
* bigfiles  - List the top 50 files based on disk usage. 
* mytuner  - MySQL Tuner. 
* highio  - Reports stats on processes in an uninterruptable sleep state. 
* mylogin  - Auto login to MySQL 
* myengines  - List MySQL tables and their storage engine. 
* myusers  - List MySQL users and grants. 
* apcheck  - Verify apache max client settings and memory usage. 
* apdocs  - Prints out Apache's DocumentRoots 
* approc  - Shows the memory used by each Apache process 
* rblcheck  - Server Email Blacklist Check 
* cloudkick - Installs the Cloudkick agent
* vhost  - Add an Apache virtual host 
* postfix  - Set up Postfix for relaying email
* parsar - Pretty sar output
* lsync  - Install lsyncd and configure this server as a master
* wordpress  - Install Wordpress on this server 
* drupal  - Install Drupal 7 on this server 
* suphp - Converts a server from mod_php to suPHP
* webmin  - Install Webmin on this server 
* concurchk  - Show concurrent connections 
* crtchk - Check SSL Cert/Key to make sure they match
* rpaf - Install mod_rpaf to set correct client IP behind a proxy.
* pma - Installs phpMyAdmin
* whatis  - Output the script that would be run with a specific command.

<p>Enjoy!</p>
