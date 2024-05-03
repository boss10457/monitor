#!/bin/bash

CurlData=$(/usr/bin/curl -m 7 -o /dev/null -k -s -w  "HTTP %{http_code} DNS %{time_namelookup} CONNECT %{time_connect} SSL %{time_appconnect} Pretransfer %{time_pretransfer} Starttransfer %{time_starttransfer} TOTAL %{time_total}" https://www.google.com)

HttpCode=$(echo $CurlData | awk '{print $2}')
DnsTime=$(echo $CurlData | awk '{print $4}')
ConnectTime=$(echo $CurlData | awk '{print ($6 - $4)}')
SslTime=$(echo $CurlData | awk '{print ($8 - $6)}')
ServerResponseTime=$(echo $CurlData | awk '{print ($12 - $10)}')
DataTransferTime=$(echo $CurlData | awk '{print ($14 - $12)}')
TotalTime=$(echo $CurlData | awk '{print $14}')


echo ''
echo HTTP ${HttpCode}
echo DNS ${DnsTime}
echo CONNECT ${ConnectTime}
echo SSL ${SslTime}
echo Pretransfer ${ServerResponseTime}
echo Starttransfer ${DataTransferTime}
echo TOTAL ${TotalTime}
