#! /usr/bin/env bash


SETIP=`cat .env.current-ip`
CURRENTIP=`dig +short myip.opendns.com @resolver1.opendns.com`

if [[ "$SETIP" != "$CURRENTIP" ]] ; then
    echo "ips set in digital ocean currently do not match local ips."
    echo "updating ips..."
    for i in `doctl compute domain records list dle.dev | grep " A " | awk '{print $1}'`; do doctl compute domain records update dle.dev --record-id $i --record-data `dig +short myip.opendns.com @resolver1.opendns.com`; done
    
else
    echo "ips match. Doing nothing"
fi


