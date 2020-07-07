#!/usr/bin/env bash
log=$1
curl --form upload=@${log} "https://srna-portal.biodata.pt/mirpursuit/logs/upload"
