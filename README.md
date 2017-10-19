# docker-odoo

Como usar esta imagem
---------------------

Comando minímo para rodar esta imagem:

```bash
▶ docker run --name odoo --net host -d -e PG_USER=odoo -e PG_PASSWORD=odoo trustcode/docker-odoo
```

Outros parâmetros:

* PG_HOST=localhost
* PG_PORT=5432
* PG_USER=odoo
* PG_PASSWORD=odoo
* PORT=8069
* LONGPOLLING_PORT=8072
* WORKERS=3

Exemplo: Trocando a porta que o Odoo vai executar para 8050

```bash
▶ docker run --name odoo --net host -d -e PG_USER=odoo -e PG_PASSWORD=odoo -e PORT=8050 trustcode/docker-odoo
```


[![Docker Repository on Quay](https://quay.io/repository/danimaribeiro/docker-odoo/status "Docker Repository on Quay")](https://quay.io/repository/danimaribeiro/docker-odoo)
