FROM quay.io/danimaribeiro/docker-odoo-base:12.0

	##### Repositórios TrustCode #####

WORKDIR /opt/odoo

RUN wget https://github.com/Trust-Code/odoo-brasil/archive/12.0.zip -O odoo-brasil.zip && \
    wget https://github.com/odoo/odoo/archive/12.0.zip -O odoo.zip && \
    wget https://github.com/Trust-Code/trustcode-addons/archive/12.0.zip -O trustcode-addons.zip

RUN unzip -q odoo-brasil.zip && rm odoo-brasil.zip && mv odoo-brasil-12.0 odoo-brasil && \
    unzip -q odoo.zip && rm odoo.zip && mv odoo-12.0 odoo && \
    unzip -q trustcode-addons.zip && rm trustcode-addons.zip && mv trustcode-addons-12.0 trustcode-addons && \
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
