# EDP Database service

This repoitory contains the migration, patches and deploy scripts for [EDPDP](https://forge.edpauto.it/stock/datastore/edpdb.git) EDP database support.

EDP Database documentation
------------


Build Status
------------

|Staging |Release |Stable |
|:------:|:------:|:------:|
|
[![build status](https://forge.edpauto.it/cariam/cariam.api/badges/master/build.svg)](https://forge.edpauto.it/cariam/cariam.api/pipelines)|[![build status](https://forge.edpauto.it/cariam/cariam.api/badges/release/0.6.0/build.svg)](https://forge.edpauto.it/cariam/cariam.api/pipelines)|[![build status](https://forge.edpauto.it/cariam/cariam.api/badges/release/0.5.0/build.svg)](https://forge.edpauto.it/cariam/cariam.api/pipelines)|


Installers and Binaries
-----------------------

Basic usage
-----------

Example of dump database command in shell:
```
./dumpdb.sh -n production -o team -m dospaces -b stack-backup -e "https://ams3.digitaloceanspaces.com" -a MP27HJ3JBRKRAAKMANOF -k WnBCAhvZbxNG2kaoMBZ5WJSRBIHP8YfCWmmhL0MXjBE -h "db.stock.prod.edpauto.tech" -u postgres -c edp -d edp -L LOGFILE -v
```
Example of restore database command in shell:
```
./restoredb.sh -n development -o dotnet -m dospaces -b stack-backup -e "https://ams3.digitaloceanspaces.com" -a MP27HJ3JBRKRAAKMANOF -k WnBCAhvZbxNG2kaoMBZ5WJSRBIHP8YfCWmmhL0MXjBE -h "db.transactions.dev.dacsoftware.it" -u postgres -c transactions -d transactions -L LOGFILE -v
```

Building from source
--------------------


Questions & Comments
--------------------

For any and all feedback, please use the Issues on this repository. 

Changelog
-------------------

Document with changes is availabled as Whats News in Cariam API services or on [website](https://forge.edpauto.it/stock/datastore/edpdb/blob/master/CHANGELOG.md).

Authors
-------------------

* [Paweł Kasperek](mailto:pawel.kasperek@edpauto.com), 2018, [DAC Software](http://dacsoftware.pl)


License
-------------------

By downloading the text file document you are agreeing to the terms in the project [EULA](https://forge.edpauto.it/stock/datastore/edpdb/blob/master/LICENSE).


