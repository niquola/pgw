echo 'install packages'
sudo apt-get update
sudo apt-get -y install git build-essential gettext libreadline6 libreadline6-dev zlib1g-dev flex bison libxml2-dev libxslt-dev || echo 'Ups. No sudo'

export PGHOME="`pwd`/pg"
mkdir $PGHOME
export PG_BRANCH=REL9_4_STABLE
export PG_REPO=git://git.postgresql.org/git/postgresql.git

echo 'clone repo'
git clone -b $PG_BRANCH --depth=1 $PG_REPO $PGHOME/src

echo 'configure'
cd $PGHOME/src && ./configure --prefix=$PGHOME && make && make install
