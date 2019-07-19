FROM quay.io/danimaribeiro/docker-odoo-base:11.0

	##### Repositórios TrustCode #####

WORKDIR /opt/odoo
RUN apt-get install -y unzip git wget gettext-base

RUN wget https://github.com/Trust-Code/odoo-product-configurator/archive/11.0.zip -O odoo-product-configurator.zip && \
    wget https://github.com/Trust-Code/trustcode-addons/archive/11.0.zip -O trustcode-addons.zip && \
    wget https://github.com/Trust-Code/odoo-brasil/archive/11.0.zip -O odoo-brasil.zip && \
    wget https://github.com/Trust-Code/odoo/archive/11.0.zip -O odoo.zip && \
    wget https://github.com/Trust-Code/stock-logistics-warehouse/archive/11.0.zip -O stock-logistics-warehouse.zip && \
    wget https://github.com/Trust-Code/queue/archive/11.0.zip -O queue.zip && \
    wget https://github.com/oca/web/archive/11.0.zip -O web.zip && \
    wget https://github.com/oca/server-ux/archive/11.0.zip -O server-ux.zip && \
    wget https://github.com/oca/reporting-engine/archive/11.0.zip -O reporting-engine.zip && \
    wget https://github.com/oca/account-financial-reporting/archive/11.0.zip -O account-financial-reporting.zip && \
    wget https://github.com/oca/mis-builder/archive/11.0.zip -O mis-builder.zip

RUN unzip -q odoo-brasil.zip && rm odoo-brasil.zip && mv odoo-brasil-11.0 odoo-brasil && \
    unzip -q odoo.zip && rm odoo.zip && mv odoo-11.0 odoo && \
    unzip -q trustcode-addons.zip && rm trustcode-addons.zip && mv trustcode-addons-11.0 trustcode-addons && \
    unzip -q odoo-product-configurator.zip && rm odoo-product-configurator.zip && mv odoo-product-configurator-11.0 odoo-product-configurator && \
    unzip -q stock-logistics-warehouse.zip && rm stock-logistics-warehouse.zip && mv stock-logistics-warehouse-11.0 stock-logistics-warehouse && \
    unzip -q queue.zip && rm queue.zip && mv queue-11.0 queue && \
    unzip -q web.zip && rm web.zip && mv web-11.0 web && \
    unzip -q server-ux.zip && rm server-ux.zip && mv server-ux-11.0 server-ux && \
    unzip -q reporting-engine.zip && rm reporting-engine.zip && mv reporting-engine-11.0 reporting-engine && \
    unzip -q account-financial-reporting.zip && rm account-financial-reporting.zip && mv account-financial-reporting-11.0 account-financial-reporting && \
    unzip -q mis-builder.zip && rm mis-builder.zip && mv mis-builder-11.0 mis-builder && \
    cd odoo && find . -name "*.po" -not -name "pt_BR.po" -not -name "pt.po"  -type f -delete && \
    find . -path "*l10n_*" -delete && \
    rm -R debian && rm -R doc && rm -R setup && cd ..

RUN pip install --no-cache-dir pytrustnfe3 python3-cnab python3-boleto pycnab240 python-sped

	##### Configurações Odoo #####

ADD conf/odoo.conf /etc/odoo/
RUN chown -R odoo:odoo /opt && \
    chown -R odoo:odoo /etc/odoo/odoo.conf

RUN mkdir /opt/.ssh && \
    chown -R odoo:odoo /opt/.ssh

ADD bin/autoupdate /opt/odoo
ADD bin/entrypoint.sh /opt/odoo
RUN chown odoo:odoo /opt/odoo/autoupdate && \
    chmod +x /opt/odoo/autoupdate && \
    chmod +x /opt/odoo/entrypoint.sh

WORKDIR /opt/odoo

ENV PG_HOST=localhost
ENV PG_PORT=5432
ENV PG_USER=odoo
ENV PG_PASSWORD=odoo
ENV PG_DATABASE=False
ENV ODOO_PASSWORD=senha_admin
ENV PORT=8069
ENV LOG_FILE=/var/log/odoo/odoo.log
ENV LONGPOLLING_PORT=8072
ENV WORKERS=3
ENV DISABLE_LOGFILE=0
ENV USE_SPECIFIC_REPO=0
ENV TRUSTCODE_APPS=0
ENV TRUSTCODE_ENTERPRISE=0
ENV TRUSTCODE_ONLY=0
ENV TIME_CPU=600
ENV TIME_REAL=720

VOLUME ["/opt/", "/etc/odoo"]
ENTRYPOINT ["/opt/odoo/entrypoint.sh"]
CMD ["/usr/bin/supervisord"]
