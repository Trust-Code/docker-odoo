FROM trustcode/docker-odoo-base:v11

	##### Repositórios TrustCode #####

WORKDIR /opt/odoo
RUN apt-get install -y unzip git

ADD https://github.com/Trust-Code/odoo-product-configurator/archive/11.0.zip odoo-product-configurator.zip
ADD https://github.com/Trust-Code/trustcode-addons/archive/11.0.zip trustcode-addons.zip
ADD https://github.com/Trust-Code/odoo-brasil/archive/11.0.zip odoo-brasil.zip
ADD https://github.com/Trust-Code/odoo/archive/11.0.zip odoo.zip
ADD https://github.com/Trust-Code/stock-logistics-warehouse/archive/11.0.zip stock-logistics-warehouse.zip
ADD https://github.com/Trust-Code/queue/archive/11.0.zip queue.zip

RUN unzip -q odoo-brasil.zip && rm odoo-brasil.zip && mv odoo-brasil-11.0 odoo-brasil && \
    unzip -q odoo.zip && rm odoo.zip && mv odoo-11.0 odoo && \
    unzip -q trustcode-addons.zip && rm trustcode-addons.zip && mv trustcode-addons-11.0 trustcode-addons && \
    unzip -q odoo-product-configurator.zip && rm odoo-product-configurator.zip && mv odoo-product-configurator-11.0 odoo-product-configurator && \
    unzip -q stock-logistics-warehouse.zip && rm stock-logistics-warehouse.zip && mv stock-logistics-warehouse-11.0 stock-logistics-warehouse && \
    unzip -q queue.zip && rm queue.zip && mv queue-11.0 queue && \
    cd odoo && find . -name "*.po" -not -name "pt_BR.po" -not -name "pt.po"  -type f -delete && \
    find . -path "*l10n_*" -delete && \
    rm -R debian && rm -R doc && rm -R setup && cd ..

RUN pip install --no-cache-dir pytrustnfe3 python3-cnab python3-boleto pycnab240 pika

	##### Configurações Odoo #####

ADD conf/odoo.conf /etc/odoo/
RUN chown -R odoo:odoo /opt && \
    chown -R odoo:odoo /etc/odoo/odoo.conf && \
    apt-get clean

WORKDIR /opt/odoo
USER odoo

ENV PG_HOST=localhost
ENV PG_PORT=5432
ENV PG_USER=odoo
ENV PG_PASSWORD=odoo
ENV PORT=8069
ENV LONGPOLLING_PORT=8072
ENV WORKERS=3

VOLUME ["/opt/", "/etc/odoo"]
CMD ["/usr/bin/supervisord"]
