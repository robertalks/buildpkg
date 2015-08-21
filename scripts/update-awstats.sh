#!/bin/sh -e
#
# awstats statistics updater script.
# part of buildpkg script.

NAME="$(basename $0 2>/dev/null)"
PREFIX="@@PREFIX@@"
AWSTATS="${PREFIX}/wwwroot/cgi-bin/awstats.pl"
DATA="@@DATA@@"
DOMAIN=$1
DATE="$(date '+%m%Y')"
USER=www

msg_error() { echo "$NAME: error: $@" >&2; }
msg_info() { echo "$NAME: info: $@"; }

usage() {
	cat << EOF
$NAME: update awstats statistics

Usage: $NAME [OPTIONS] <domain_name>...

        --help          Show help
        --all           Updates all statistics for all available domains

Example:
      $NAME youdomain.com
    or
      $NAME --all

EOF
}

update_per_domain()
{
	local domain="$1"
	local config=""

	if [ "${domain}" = "" ]; then
		msg_error "missing domain."
		exit 1
	fi

	config="${PREFIX}/conf/awstats.${domain}.conf"
	if [ -e ${config} ]; then
		msg_info "running web statistics update on domain ${domain} ..."
		${AWSTATS} -update -config=${domain} >/dev/null 2>&1
		if [ $? -ne 0 ]; then
			msg_error "failed to update web statistics for domain ${domain}."
			exit 1
		fi
	else
		msg_error "missing awstats domain ${domain} configuration file."
		exit 1
	fi

	if [ -e ${DATA}/awstats${DATE}.${domain}.txt ]; then
		if [ "$(stat -c %U ${DATA}/awstats${DATE}.${domain}.txt)" != "${USER}" ]; then
			chown ${USER} ${DATA}/awstats${DATE}.${domain}.txt >/dev/null 2>&1
		fi
	fi
	if [ -e ${DATA}/dnscachelastupdate.${domain}.txt ]; then
		if [ "$(stat -c %U ${DATA}/dnscachelastupdate.${domain}.txt)" != "${USER}" ]; then
			chown ${USER} ${DATA}/dnscachelastupdate.${domain}.txt >/dev/null 2>&1
		fi
	fi
}

update_all()
{
	local files="$(find ${PREFIX}/conf \( -name awstats.\*.conf \) -a \( ! -name awstats.model.conf \) -type f)"

	if [ "${files}" = "" ]; then
		msg_info "nothing to update, not configuration files found."
		exit 0
	else
		for conf in ${files}; do
			domain="$(grep "^SiteDomain" ${conf} 2>/dev/null | cut -f 2 -d\" 2>/dev/null)"
			update_per_domain "${domain}"
		done
	fi
}

if [ $# -eq 0 ]; then
	usage
	msg_error "missing option or domain name."
	exit 1
fi

if [ ! -x ${AWSTATS} ]; then
	msg_error "awstats perl script missing."
	exit 1
fi

if [ "${DOMAIN}" = "--help" ]; then
	usage
elif [ "${DOMAIN}" = "--all" ]; then
	update_all
elif
	update_per_domain ${DOMAIN}
fi

exit 0
