# Trustcode - Oficial docker image for Odoo 

How do use this docker image ?
---------------------

tldr; Minimal command to run this image

```bash
▶ docker run --name odoo --net host -d -e PG_USER=odoo -e PG_PASSWORD=odoo trustcode/docker-odoo:11.0
```

Other parameters:

* PG_HOST=localhost
* PG_PORT=5432
* PG_USER=odoo
* PG_PASSWORD=odoo
* PORT=8069
* LONGPOLLING_PORT=8072
* WORKERS=3
* ODOO_PASSWORD=senha_admin
* DISABLE_LOGFILE=0
* ODOO_ENTERPRISE=1
* TRUSTCODE_ENTERPRISE=1
* ODOO_VERSION=11.0

Example: Switching the port on which Odoo will listen to:

```bash
▶ docker run --name odoo --net host -d -e PG_USER=odoo -e PG_PASSWORD=odoo -e PORT=8050 trustcode/docker-odoo:11.0
```

Preferred way:
---------------------

Install [docker-compose](https://docs.docker.com/compose/install/) to manage docker containers.

Create a docker-compose file following this example:
```yaml
version: '3'
services:
  odoo-update:
    image: trustcode/docker-odoo:11.0
    network_mode: host
    volumes:
      - ~/.ssh:/home/temp/.ssh
      - ~/dados:/opt/dados
    environment:
      PG_USER: postgres_user
      PG_PASSWORD: 123
      ODOO_VERSION: 11.0
      ODOO_ENTERPRISE: 1
      TRUSTCODE_ENTERPRISE: 1
      DATABASE: database
      DISABLE_LOGFILE: 1
```

Parameters:

- ODOO_ENTERPRISE - download the enterprise version (it needs a valid ssh key to be mounted under /home/temp/.ssh)
- TRUSTCODE_ENTERPRISE - download private modules from Trustcode
- DATABASE - optional database name (required if you use autoupdate command when run the image)
- DISABLE_LOGFILE - disable odoo logs to a file, instead output to standard (useful with autoupdate)

Change the parameters as you want and run:
```bash
▶ docker-compose up
```

Updating the Odoo instance
----------------------------------

Download the latest version of this docker image and follow below. We run daily builds of this image, it's safer to run this process in your Odoo instance at same periodicity.

If you want to update your Odoo instance just add to your docker-compose file the following command:
```yaml
    image: trustcode/docker-odoo:11.0
    command: autoupdate
    network_mode: host
```
But before run this you should install the module "module_auto_update", without the module installed in the database the above command will not update Odoo. More info on the [module](https://github.com/OCA/server-tools/tree/11.0/module_auto_update).


Using for development and testing:
-----------------------------------

Download this repository, change the environment variables in docker-compose.yml and run:
```bash
▶ docker-compose build && docker-compose up
```


[![Docker Repository on Quay](https://quay.io/repository/danimaribeiro/docker-odoo/status "Docker Repository on Quay")](https://quay.io/repository/danimaribeiro/docker-odoo)

Trustcode Sistemas Empresariais
----------------
![Trustcode](http://www.trustcode.com.br/logo.png)
