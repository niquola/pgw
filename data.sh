#!/bin/bash
source `pwd`/env.sh

mkdir -p $PGDATA
initdb -D $PGDATA -E utf8

echo "host all  all    0.0.0.0/0  md5" >> $PGDATA/pg_hba.conf
echo "listen_addresses='*'" >> $PGDATA/postgresql.conf
echo "port=$PGPORT" >> $PGDATA/postgresql.conf

pg_ctl -D $ROOT/data -w start
createuser -s db
psql postgres -c "alter user db with password 'db'"
psql postgres -c "create database app;"

psql app < app.sql
