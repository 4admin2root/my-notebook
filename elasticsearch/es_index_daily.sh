#!/bin/bash

# Jason Lui

es_index_log=/tmp/es_index.log

yesterday=`date -d "1  days ago"  "+%Y.%m.%d"`

daysago=`date -d "108  days ago"  "+%Y.%m.%d"`

es_url="http://172.21.2.40:9200/"

index_keywords=("application" "nginx_frontend" "nginx_backend")

# print current segments info
echo `########## start ########` >> ${es_index_log}
echo `date +"%Y-%m-%d"` >> ${es_index_log}
curl -s "${es_url}_cat/nodes?v&h=name,segments.count,segments.memory,segments.index_writer_memory,segments.version_map_memory,segments.fixed_bitset_memory" >> ${es_index_log}

# close indexes
for i in ${index_keywords[@]}; do
echo "close index: ${i}" >> ${es_index_log}
curl -XPOST -s "${es_url}${i}*${daysago}/_close" -d '' >> ${es_index_log}
sleep 10
done

# merge indexes
for i in ${index_keywords[@]}; do
echo "merge index: ${i}" >> ${es_index_log}
curl -XPOST -s "${es_url}${i}*${yesterday}/_forcemerge?max_num_segments=1" -d '' >> ${es_index_log}
sleep 100
done

curl -s "${es_url}_cat/nodes?v&h=name,segments.count,segments.memory,segments.index_writer_memory,segments.version_map_memory,segments.fixed_bitset_memory" >> ${es_index_log}
