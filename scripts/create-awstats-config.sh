#!/bin/bash
#
# awstats config generator
# part of buildpkg script.

set -e

NAME=$(basename $0)
DOMAIN=$1
DATA=@@DATA@@
MODEL=@@PREFIX@@/conf/awstats.model.conf
CONFIGDIR=@@PREFIX@@/conf
NEWCONFIG="${CONFIGDIR}/awstats.${DOMAIN}.conf"
WWWUSER=www
_UID=$(id -u 2>/dev/null)

if [ $# -eq 0 ]; then
   echo "${NAME}: error: missing host/domain name argument."
   echo "${NAME}: usage: ${NAME} <hostname>"
   exit 1
fi

if [ ! -d ${CONFIGDIR} ]; then
   echo "${NAME}: error: ${CONFIGDIR} missing, awstats mignt not be properly installed."
   exit 1
fi

if [ ! -e ${MODEL} ]; then
   echo "${NAME}: error: ${MODEL} config model missing."
   echo "${NAME}: error: can't generate new configuration if config model is missing."
   exit 1
fi

if [ $_UID -ne 0 ]; then
   echo "${NAME}: error: config generator must be run as root user."
   exit 1
fi

if [ $(getent passwd ${WWWUSER} >/dev/null 2>&1; echo $?) -ne 0 ]; then
   echo "${NAME}: error: ${WWWUSER} missing, please reinstall the web server and try again."
   exit 1
fi

if [ ! -e /var/log/nginx/${DOMAIN}-access.log ]; then
   echo "${NAME}: error: /var/log/nginx/${DOMAIN}-access.log access log file not found."
   echo "${NAME}: error: make sure you have everything setup correctly and that the domain is correct."
   exit 1
fi

if [ -e ${NEWCONFIG} ]; then
   echo "${NAME}: error: ${NEWCONFIG} already exists, we wont overwrite it."
   exit 1
fi

[ -d ${DATA} ] || mkdir -p ${DATA} >/dev/null 2>&1

REGEX="$(echo ${DOMAIN}|sed 's/[.]/\\\\./g')"

cp -af ${MODEL} ${NEWCONFIG}
sed -i \
  -e "s|^DNSLookup=.*|DNSLookup=1|" \
  -e "s|^LogFile=.*|LogFile=/var/log/nginx/${DOMAIN}-access.log|" \
  -e "s|^SiteDomain=.*|SiteDomain=\"${DOMAIN}\"|" \
  -e "s|^DirData=.*|DirData=\"${DATA}\"|" \
  -e "s|^HostAliases.*|HostAliases=\"localhost 127.0.0.1 REGEX[${REGEX}$]\"|g" \
  ${NEWCONFIG}

echo "${NAME}: info: ${NEWCONFIG} configuration file generated."
echo "${NAME}: info: please run update-awstats.sh script to generate the first statistics for domain ${DOMAIN}."

exit 0
