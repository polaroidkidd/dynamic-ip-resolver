#! /usr/bin/env bash


IP=".env.current-ip"

if [[ -f "$IP" ]] ; then
    echo "removing previous $IP"
    rm .env.current-ip
fi

echo `dig +short myip.opendns.com @resolver1.opendns.com` > .env.current-ip