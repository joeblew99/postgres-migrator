#!/bin/bash

set -e

cwd=$(pwd)

cd /home/postgres/.lib/pgmigrator/src

sudo ./dumpdb.sh -n production -o team -m dospaces -b stack-backup -e "https://ams3.digitaloceanspaces.com" -a CBRHRHJLN6XKJJWXJPBB -k Q7h1oDIvkO3Qur9RF6DECtUjJnGiScJzguzIvZpARew -h "localhost" -r "db.qarson.fr" -u postgres -c qarson -d qarson_fr -L LOGFILE -v

sudo ./dumpdb.sh -n production -o team -m dospaces -b stack-backup -e "https://ams3.digitaloceanspaces.com" -a CBRHRHJLN6XKJJWXJPBB -k Q7h1oDIvkO3Qur9RF6DECtUjJnGiScJzguzIvZpARew -h "localhost" -r "db.qarson.fr" -u postgres -c qarson -d edpauto_fr -L LOGFILE -v

cd $(pwd)

exit 0
