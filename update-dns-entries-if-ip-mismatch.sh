#! /usr/bin/env bash


SETIP=`cat .env.current-ip`
CURRENTIP=`dig +short myip.opendns.com @resolver1.opendns.com`

if [[ "$SETIP" != "$CURRENTIP" ]] ; then
    printf '%s %s\n' "$(date): IPs do not match. Will update them."
#    for i in `doctl compute domain records list dle.dev | grep " A " | awk '{print $1}'`; do doctl compute domain records update dle.dev --record-id $i --record-data `dig +short myip.opendns.com @resolver1.opendns.com`; done
    bash ./current-ip.sh   
else
    printf '%s %s\n' "$(date): IPs Match."
fi


