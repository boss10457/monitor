#!/bin/bash
#array format ,  [var name] =([data1] [data2])

src_host=(
    GCP_10.4.255.12
)

dst_ip=(
    192.168.142.65
)

dst_url=(
    http://192.168.142.65/api/single_wallet/health
)

dst_header=(
    "host:bb.durian"
)

dst_path=(
    GCP_XPN1_RD5F5_RD5SingleVM_HTTP_192.168.142.65
)

db_host=(
    10.4.255.11
)

db_name=(
    monitor_srv
)

db_table=(
    monitor_curl_xpn
)

cfg_ignore=(
    off
)

cfg_ignore_ms=(
    0.025
)

function CurlNavigation {
    GetTimeStamp=$(date +%s%N)

    CfgIgnore=${cfg_ignore[${1}]}
    CfgIgnoreMs=${cfg_ignore_ms[${1}]}

    SrcHost=${src_host[${1}]}

    DstIp=${dst_ip[${1}]}
    DstUrl=${dst_url[${1}]}
    DstHeader=${dst_header[${1}]}
    DstPath=${dst_path[${1}]}

    DbHost=${db_host[${1}]}
    DbName=${db_name[${1}]}
    DbTable=${db_table[${1}]}
    DbUser="monitor"
    DbPasswd="monitor"

    CurlData=$(/usr/bin/curl -m 22 -o /dev/null -k -s -w  "HTTP %{http_code} DNS %{time_namelookup} \ 
    CONNECT %{time_connect} SSL %{time_appconnect} Pretransfer %{time_pretransfer} \ 
    Starttransfer %{time_starttransfer} TOTAL %{time_total}" $DstUrl -H $DstHeader)

    # echo $CurlData
    HttpCode=$(echo $CurlData | awk '{print $2}')
    DnsTime=$(echo $CurlData | awk '{print $4}')
    ConnectTime=$(echo $CurlData | awk '{print ($6 - $4)}')
    SslTime=$(echo $CurlData | awk '{print ($8 - $6)}')
    # HungTime=$(echo $CurlData | awk '{print ($10 - $8)}') # TCP 建立完成後與發出請求之間的時間差，為kernel處理時間
    ServerResponseTime=$(echo $CurlData | awk '{print ($12 - $10)}')
    DataTransferTime=$(echo $CurlData | awk '{print ($14 - $12)}')
    TotalTime=$(echo $CurlData | awk '{print $14}')

    #code = 200 and TotalTime < xxx ms  , no send to db
    if [ $CfgIgnore == 'on' ];then
    	if [ $HttpCode = '200' ] && [ $(echo "$TotalTime < $CfgIgnoreMs" | bc) = 1  ] ; then
                    return
    	fi
    fi

    #Send to InfluxDB
    /usr/bin/curl -o /dev/null -s -i -XPOST "http://$DbHost:8086/write?db=$DbName" -u $DbUser:$DbPasswd --data-binary "$DbTable,src=$SrcHost,dst_ip=$DstIp,dst_url=$DstUrl,dst_path=$DstPath,http_code=$HttpCode HttpCode=$HttpCode,DnsTime=$DnsTime,ConnectTime=$ConnectTime,SslTime=$SslTime,ServerResponseTime=$ServerResponseTime,DataTransferTime=$DataTransferTime,TotalTime=$TotalTime $GetTimeStamp" & > /dev/null 2>&1

}

for f02 in {1..60}
do
    for ((f01=0 ; f01 < ${#dst_url[@]} ; f01++))
    do
        CurlNavigation $f01 &
        sleep 0.01
    done
    sleep 1
done
