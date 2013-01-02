#!/bin/bash
#
# awstats statistics updater script.
# part of buildpkg script.

PREFIX="@@PREFIX@@"
AWSTATS="${PREFIX}/wwwroot/cgi-bin/awstats.pl"
DATA="@@DATA@@"
DOMAIN=$1

msg_error()
{
 local msg="$1"
 local name="$(basename $0 2>/dev/null)"
 echo "${name}: error: ${msg}"
}

msg_info()
{
 local msg="$1"
 local name="$(basename $0 2>/dev/null)"
 echo "${name}: info: ${msg}"
}

update_per_domain()
{
  local domain=$1
  local config="${PREFIX}/conf/awstats.${domain}.conf"

  if [ "${domain}" = "" ]; then
     msg_error "missing domain."
     exit 1
  fi

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
}

update_all()
{
 local files="$(find ${PREFIX}/conf \( -name awstats.\*.conf \) -a \( ! -name awstats.model.conf \) -type f)"
 if [ "${files}" = "" ]; then
    msg_info "nothing to update, not configuration files found."
    exit 0
 else
    for conf in ${files}; do
	domain="$(grep "^SiteDomain" ${conf} 2>/dev/null | cut -f 2 -d'=' 2>/dev/null | tr -d '"' 2>/dev/null)"
        update_per_domain "${domain}"
    done
 fi
}

if [ $# -eq 0 ]; then
   msg_error "missing arguments."
   msg_info "usage: <script> <domain> (updates all statistics per given domain)"
   msg_info "usage: <script> --all (updates all statistics for all available domains)"
   exit 1
fi

if [ ! -x ${AWSTATS} ]; then
   msg_error "awstats perl script missing."
   exit 1
fi

if [ "${DOMAIN}" = "--all" ]; then
   update_all
else
   update_per_domain ${DOMAIN}
fi

exit 0
