#!/bin/bash

/usr/bin/curl -m 7 -o /dev/null -k -s -w  "HTTP %{http_code} DNS %{time_namelookup} CONNECT %{time_connect} SSL %{time_appconnect} Pretransfer %{time_pretransfer} Starttransfer %{time_starttransfer} TOTAL %{time_total}" https://www.google.com

echo "HTTP %{http_code}""
echo "DNS %{time_namelookup}""
echo "CONNECT %{time_connect}""
echo "SSL %{time_appconnect}""
echo "Pretransfer %{time_pretransfer}""
echo "Starttransfer %{time_starttransfer}""
echo "TOTAL %{time_total}""
