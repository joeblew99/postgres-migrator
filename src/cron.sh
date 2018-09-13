#!/bin/bash

set -e

cwd=$(pwd)

cd /home/postgres/.lib/pgmigrator/src

#sudo ./dumpdb.sh -n production -o team -m dospaces -b stack-backup -e "https://ams3.digitaloceanspaces.com" -a CBRHRHJLN6XKJJWXJPBB -k Q7h1oDIvkO3Qur9RF6DECtUjJnGiScJzguzIvZpARew -h "localhost" -u postgres -c edp -d edp -L LOGFILE -v

sudo ./dumpdb.sh -n production -o team -m dospaces -b stack-backup -e "https://ams3.digitaloceanspaces.com" -a CBRHRHJLN6XKJJWXJPBB -k Q7h1oDIvkO3Qur9RF6DECtUjJnGiScJzguzIvZpARew -h "localhost" -r "db.stock.prod.edpauto.tech" -u postgres -c edp -d pgcrontab -L LOGFILE -v

sudo ./dumpdb.sh -n production -o team -m dospaces -b stack-backup -e "https://ams3.digitaloceanspaces.com" -a CBRHRHJLN6XKJJWXJPBB -k Q7h1oDIvkO3Qur9RF6DECtUjJnGiScJzguzIvZpARew -h "db.cariam.prod.edpauto.tech" -u postgres -c cariam -d currencies -L LOGFILE -v

#sudo ./dumpdb.sh -n production -o team -m dospaces -b stack-backup -e "https://ams3.digitaloceanspaces.com" -a CBRHRHJLN6XKJJWXJPBB -k Q7h1oDIvkO3Qur9RF6DECtUjJnGiScJzguzIvZpARew -h "db.cariam.prod.edpauto.tech" -u postgres -c cariam -d identity -L LOGFILE -v

#sudo ./dumpdb.sh -n production -o team -m dospaces -b stack-backup -e "https://ams3.digitaloceanspaces.com" -a CBRHRHJLN6XKJJWXJPBB -k Q7h1oDIvkO3Qur9RF6DECtUjJnGiScJzguzIvZpARew -h "db.cariam.prod.edpauto.tech" -u postgres -c cariam -d cariam -L LOGFILE -v

cd $(pwd)

exit 0
