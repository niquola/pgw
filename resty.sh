sudo apt-get update
sudo apt-get install libreadline-dev \
  curl \
  libncurses5-dev \
  libpcre3-dev \
  libssl-dev \
  perl \
  make \

VERSION='1.7.2.1'
curl http://openresty.org/download/ngx_openresty-$VERSION.tar.gz > openresty.tar.gz
tar xzvf openresty.tar.gz
mv ngx_openresty-$VERSION openresty
rm openresty.tar.gz

BLD=`pwd`

cd openresty

./configure --prefix=$BLD \
  --with-lua51 \
  --with-pcre \
  --with-ipv6 \
  --with-pg_config=$BLD/pg/bin/pg_config \
  --with-http_postgres_module \
  -j4

#  --with-luajit \
#  --with-pcre-jit \

make & make install

cd $BLD

rm  nginx/conf/nginx.conf
ln -s $BLD/nginx.conf nginx/conf/nginx.conf
ls -lah nginx/conf/nginx.conf

exit 0

