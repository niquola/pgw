source ./env.sh

mkdir -p $PGDATA
initdb -D $PGDATA -E utf8

echo "host all  all    0.0.0.0/0  md5" >> $PGDATA/pg_hba.conf
echo "listen_addresses='*'" >> $PGDATA/postgresql.conf
echo "port=$PGPORT" >> $PGDATA/postgresql.conf

pg_ctl -D $HOME/data -w start && psql postgres -c "alter user db with password 'db'; create database app;"

psql app < app.sql
