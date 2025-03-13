#!/bin/env bash

# low memory instances can be affected when using Raster 
# DDoS Associate with PostGIS

host_rds="$1"
port_rds="5432"
db_name="postgisdb"

user="asdf"

root_cert="./any-root-cert.pem"  #
#ssl_mode="verify-full"   ##verify-full
ssl_mode="allow"   ##verify-full

PG_CMD="psql -h ${host_rds} -p ${port_rds} \"dbname=${db_name} user=${user} sslrootcert=${root_cert} sslmode=${ssl_mode}\""

SQL=" explain analyze select encode(St_AsGDALRaster(St_Union(rast), 'GTiff', Array['COMPRESS=LZW']), 'hex') as content from all_tmax ;"
#SQL=" explain analyze select St_AsGDALRaster(St_Union(rast), 'GTiff', Array['COMPRESS=LZW']) as content from tmax01 ;"

if [ ! -z "${SQL}" ]
then
  PG_CMD="${PG_CMD} -c \" ${SQL} \"" 
fi

for i in {1..25}
do
   echo "Run $i: `date`"
   #echo "${PG_CMD}"
   eval ${PG_CMD} & 
   #sleep 1
done;
