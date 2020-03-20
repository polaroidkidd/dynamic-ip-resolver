#! /usr/bin/env bash
set -e
while getopts d: option; do
  case "${option}" in

  d) DOMAIN=${OPTARG} ;;
  esac
done

if ! [[ -v DOMAIN ]]; then
  printf "Please pass a domain name to the script. Usage is ./update-dns-entries-if-ip-mismatch.sh -d my-domain"
  exit 1
fi

DYNAMIC_IP_RESOLVER_DNS_IP_WORK_PATH=$(dirname "$0")
DYNAMIC_IP_RESOLVER_DNS_IP_WORK_PATH=$( (cd "$WORK_PATH" && pwd))

if ! [[ -f "$DYNAMIC_IP_RESOLVER_DNS_IP_WORK_PATH/.env" ]] ; then
  echo $(doctl compute domain records list "$DOMAIN" | grep " A " | awk 'NR==1{print $4}') > "$DYNAMIC_IP_RESOLVER_DNS_IP_WORK_PATH/.env"
  wait
  printf '%s %s\n' "$(date): The $DYNAMIC_IP_RESOLVER_DNS_IP_WORK_PATH/.env doesn't exist. Placing your DNS IP ($(cat "$DYNAMIC_IP_RESOLVER_DNS_IP_WORK_PATH/.env")) in the .env file."
fi

DYNAMIC_IP_RESOLVER_DNS_IP=$(cat "$DYNAMIC_IP_RESOLVER_DNS_IP_WORK_PATH/.env")

if [[ -z "$DYNAMIC_IP_RESOLVER_DNS_IP" ]] ; then
    printf '%s %s\n' "$(date): The $DYNAMIC_IP_RESOLVER_DNS_IP_WORK_PATH/.env is empty. Placing your DNS IP ($DYNAMIC_IP_RESOLVER_DNS_IP) in the .env file."
    echo $(doctl compute domain records list "$DOMAIN" | grep " A " | awk 'NR==1{print $4}') >"$DYNAMIC_IP_RESOLVER_DNS_IP_WORK_PATH/.env"
    DYNAMIC_IP_RESOLVER_DNS_IP=$(cat "$DYNAMIC_IP_RESOLVER_DNS_IP_WORK_PATH/.env")
fi

DYNAMIC_IP_RESOLVER_RETRIEVED_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)

if [[ "$DYNAMIC_IP_RESOLVER_DNS_IP" != "$DYNAMIC_IP_RESOLVER_RETRIEVED_IP" ]]; then
  printf '%s %s\n' "$(date): IPs do not match. Updating DNS Entries"
  for i in $(doctl compute domain records list dle.dev | grep " A " | awk '{print $1}'); do doctl compute domain records update dle.dev --record-id $i --record-data `dig +short myip.opendns.com @resolver1.opendns.com`; done
  wait
  printf '%s %s\n' "$(date): Updating ENV DYNAMIC_IP_RESOLVER_DNS_IP to contain: $DYNAMIC_IP_RESOLVER_RETRIEVED_IP"

  if [[ -f $DYNAMIC_IP_RESOLVER_DNS_IP_WORK_PATH/.env ]]; then
    rm ""$DYNAMIC_IP_RESOLVER_DNS_IP_WORK_PATH/.env""
    echo "$DYNAMIC_IP_RESOLVER_RETRIEVED_IP" > "$DYNAMIC_IP_RESOLVER_DNS_IP_WORK_PATH/.env"
  fi
else
  printf '%s %s\n' "$(date): IPs Match. Doing nothing."
fi
