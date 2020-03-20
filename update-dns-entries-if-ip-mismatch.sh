#! /usr/bin/env bash
set -e
while getopts d: option
    do
        case "${option}"
    in
        d) DOMAIN=${OPTARG};;
    esac
done

if ! [[ -v DOMAIN ]] ; then
    printf "Please pass a domain name to the script. Usage is ./update-dns-entries-if-ip-mismatch.sh -d my-domain"
    exit 1
fi

DOES_DOMAIN_EXIST=`doctl projects list | awk '{print $4}' | grep "$DOMAIN"`
wait

if [[ -z "$DOES_DOMAIN_EXIST" ]]; then
    printf "doctl appears to have trouble with the domain/project ($DOMAIN). Exiting"
    exit 1
fi


if ! [[ -v DYNAMIC_IP_RESOLVER_DNS_IP ]] ; then
    export DYNAMIC_IP_RESOLVER_DNS_IP=`doctl compute domain records list "$DOMAIN" | grep " A " | awk 'NR==1{print $4}'`
    wait
    printf '%s %s\n' "$(date): Running script for the first time. Placing your IP ($DYNAMIC_IP_RESOLVER_DNS_IP) in the env DYNAMIC_IP_RESOLVER_DNS_IP."
    
elif [[ -z "$DYNAMIC_IP_RESOLVER_DNS_IP" ]] ; then
    export DYNAMIC_IP_RESOLVER_DNS_IP=`doctl compute domain records list dle.dev | grep " A " | awk 'NR==1{print $4}'`
    printf '%s %s\n' "$(date): The ENV DYNAMIC_IP_RESOLVER_DNS_IP is empty. Updating it to contain $DYNAMIC_IP_RESOLVER_DNS_IP."
fi

DYNAMIC_IP_RESOLVER_RETRIEVED_IP=`dig +short myip.opendns.com @resolver1.opendns.com`

if [[ "$DYNAMIC_IP_RESOLVER_DNS_IP" != "$DYNAMIC_IP_RESOLVER_RETRIEVED_IP" ]] ; then
    printf '%s %s\n' "$(date): IPs do not match. Updating DNS Entries"
    for i in `doctl compute domain records list dle.dev | grep " A " | awk '{print $1}'`; do doctl compute domain records update dle.dev --record-id $i --record-data `dig +short myip.opendns.com @resolver1.opendns.com`; done
    wait
    printf '%s %s\n' "$(date): Updating ENV DYNAMIC_IP_RESOLVER_DNS_IP to contain: $DYNAMIC_IP_RESOLVER_RETRIEVED_IP"
    export DYNAMIC_IP_RESOLVER_DNS_IP="$DYNAMIC_IP_RESOLVER_RETRIEVED_IP"
else
    printf '%s %s\n' "$(date): IPs Match."
fi
