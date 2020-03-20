#! /usr/bin/env bash


IP=`dig +short myip.opendns.com @resolver1.opendns.com`

if [[ -f ".env.current-ip" ]] ; then
    rm .env.current-ip
fi
printf '%s %s\n' "$(date): Updating ip file to contain $IP"
echo `dig +short myip.opendns.com @resolver1.opendns.com` > .env.current-ip
