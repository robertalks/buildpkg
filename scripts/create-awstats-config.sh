#!/bin/sh -e
#
# awstats config generator
# part of buildpkg script.

NAME="$(basename $0)"
DOMAIN="$1"
DATA="@@DATA@@"
MODEL="@@PREFIX@@/conf/awstats.model.conf"
CONFIGDIR="@@PREFIX@@/conf"
NEWCONFIG="${CONFIGDIR}/awstats.${DOMAIN}.conf"
WWWUSER="www"
ID=$(id -u 2>/dev/null || echo 1)

_info() { echo "$NAME: $@"; }
_error() { echo "$NAME: error: $@" >&2; }

if [ $# -eq 0 ]; then
	_error "expected domain name" >&2
	_info "usage: $NAME <domain_name>"
	exit 1
fi

if [ ! -d ${CONFIGDIR} ]; then
	_error "${CONFIGDIR} missing, awstats might not be properly installed." >&2
	exit 1
fi

if [ ! -e ${MODEL} ]; then
	_error "${MODEL} config model missing."
	_error "can't generate new configuration if config model is missing."
	exit 1
fi

if [ $ID -ne 0 ]; then
	_error "config generator must be run as root user."
	exit 1
fi

if ! getent passwd ${WWWUSER} >/dev/null 2>&1; then
	_error "${WWWUSER} missing, please reinstall the web server and try again."
	exit 1
fi

if [ ! -e /var/log/nginx/${DOMAIN}-access.log ]; then
	_error "/var/log/nginx/${DOMAIN}-access.log access log file not found."
	_error "make sure you have everything setup correctly and that the domain is correct."
	exit 1
fi

if [ -e ${NEWCONFIG} ]; then
	_error "${NEWCONFIG} already exists, we wont overwrite it."
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
	-e "s|^AllowToUpdateStatsFromBrowser=.*|AllowToUpdateStatsFromBrowser=1|g" \
	-e "s|^AllowFullYearView=.*|AllowFullYearView=3|g" \
	-e "s|^EnableLockForUpdate=.*|EnableLockForUpdate=1|g" \
	${NEWCONFIG}

chmod 0644 ${NEWCONFIG} >/dev/null 2>&1

_info "info: ${NEWCONFIG} configuration file generated."
_info "info: please run update-awstats.sh script to generate the first statistics for domain ${DOMAIN}."

exit 0
