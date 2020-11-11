FROM trustcode/docker-odoo-base:13.0

	##### Repositórios TrustCode #####
WORKDIR /opt/odoo

RUN wget https://github.com/Trust-Code/odoo/archive/13.0.zip -O odoo.zip && \
    wget https://github.com/oca/server-ux/archive/13.0.zip -O server-ux.zip && \
    wget https://github.com/oca/reporting-engine/archive/13.0.zip -O reporting-engine.zip && \
    wget https://github.com/oca/account-financial-reporting/archive/13.0.zip -O account-financial-reporting.zip && \
    wget https://github.com/oca/mis-builder/archive/13.0.zip -O mis-builder.zip && \
    wget https://github.com/Trust-Code/helpdesk/archive/13.0.zip -O helpdesk.zip && \
    wget https://github.com/Trust-Code/odoo-themes/archive/13.0.zip -O odoo-themes.zip && \
    wget https://github.com/Trust-Code/odoo-brasil/archive/13.0.zip -O odoo-brasil.zip && \
    wget https://github.com/code-137/odoo-apps/archive/13.0.zip -O code137-apps.zip

RUN unzip -q odoo.zip && rm odoo.zip && mv odoo-13.0 odoo && \
    unzip -q server-ux.zip && rm server-ux.zip && mv server-ux-13.0 server-ux && \
    unzip -q reporting-engine.zip && rm reporting-engine.zip && mv reporting-engine-13.0 reporting-engine && \
    unzip -q account-financial-reporting.zip && rm account-financial-reporting.zip && mv account-financial-reporting-13.0 account-financial-reporting && \
    unzip -q mis-builder.zip && rm mis-builder.zip && mv mis-builder-13.0 mis-builder && \
    unzip -q helpdesk.zip && rm helpdesk.zip && mv helpdesk-13.0 helpdesk && \
    unzip -q odoo-themes.zip && rm odoo-themes.zip && mv odoo-themes-13.0 odoo-themes && \
    unzip -q odoo-brasil.zip && rm odoo-brasil.zip && mv odoo-brasil-13.0 odoo-brasil && \
    unzip -q code137-apps.zip && rm code137-apps.zip && mv odoo-apps-13.0 code137-apps && \
    cd odoo && find . -name "*.po" -not -name "pt_BR.po" -not -name "pt.po"  -type f -delete && \
    find . -path "*l10n_*" -delete && \
    rm -R debian && rm -R doc && rm -R setup && cd ..

RUN pip install --no-cache-dir pytrustnfe3 python3-cnab python3-boleto pycnab240 python-sped

	##### Configurações Odoo #####

ADD deploy/odoo.conf /etc/odoo/
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

ENV PYTHONPATH=$PYTHONPATH:/opt/odoo/odoo
ENV PG_HOST=localhost
ENV PG_PORT=5432
ENV PG_USER=odoo
ENV PG_PASSWORD=odoo
ENV PG_DATABASE=False
ENV ODOO_PASSWORD=admin
ENV PORT=8069
ENV LOG_FILE=/var/log/odoo/odoo.log
ENV LONGPOLLING_PORT=8072
ENV WORKERS=5
ENV DISABLE_LOGFILE=0
ENV USE_SPECIFIC_REPO=0
ENV TRUSTCODE_APPS=0
ENV TRUSTCODE_ENTERPRISE=0
ENV TRUSTCODE_ONLY=0
ENV TIME_CPU=6000
ENV TIME_REAL=7200

VOLUME ["/opt/", "/etc/odoo"]
ENTRYPOINT ["/opt/odoo/entrypoint.sh"]
CMD ["/usr/bin/supervisord"]