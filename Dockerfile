FROM trustcode/docker-odoo-base:8.0

	##### Repositórios TrustCode #####

WORKDIR /opt/odoo
RUN apt-get install -y unzip git

ADD https://github.com/Trust-Code/l10n-brazil/archive/8.0.zip l10n-brazil.zip
ADD https://github.com/Trust-Code/odoo-brazil-eletronic-documents/archive/8.0.zip odoo-brazil-eletronic-documents.zip
ADD https://github.com/Trust-Code/odoo-brazil-banking/archive/8.0.zip odoo-brazil-banking.zip
ADD https://github.com/Trust-Code/server-tools/archive/8.0.zip server-tools.zip
ADD https://github.com/Trust-Code/account-financial-reporting/archive/8.0.zip account-financial-reporting.zip
ADD https://github.com/Trust-Code/odoo-utils/archive/8.0.zip odoo-utils.zip
ADD https://github.com/Trust-Code/account-fiscal-rule/archive/8.0.zip account-fiscal-rule.zip
ADD https://github.com/Trust-Code/project/archive/8.0.zip project.zip
ADD https://github.com/Trust-Code/odoo-project_scrum/archive/8.0.zip odoo-project_scrum.zip
ADD https://github.com/Trust-Code/trust-themes/archive/8.0.zip trust-themes.zip
ADD https://github.com/Trust-Code/trust-addons/archive/8.0.zip trust-addons.zip
ADD https://github.com/OCA/web/archive/8.0.zip web.zip
ADD https://github.com/OCA/account-financial-tools/archive/8.0.zip account-financial-tools.zip
ADD https://github.com/OCA/bank-statement-import/archive/8.0.zip bank-statement-import.zip
ADD https://github.com/OCA/partner-contact/archive/8.0.zip partner-contact.zip
ADD https://github.com/OCA/account-payment/archive/8.0.zip account-payment.zip
ADD https://github.com/OCA/reporting-engine/archive/8.0.zip reporting-engine.zip
ADD https://github.com/OCA/account-reconcile/archive/8.0.zip account-reconcile.zip
ADD https://github.com/OCA/bank-payment/archive/8.0.zip bank-payment.zip
ADD https://github.com/odoo/odoo/archive/8.0.zip odoo.zip

RUN unzip -q l10n-brazil.zip && rm l10n-brazil.zip && mv l10n-brazil-8.0 l10n-brazil && \
    unzip -q odoo.zip && rm odoo.zip && mv odoo-8.0 odoo && \
		unzip -q odoo-brazil-eletronic-documents.zip && rm odoo-brazil-eletronic-documents.zip && mv odoo-brazil-eletronic-documents-8.0 eletronic-docs && \
    unzip -q odoo-brazil-banking.zip && rm odoo-brazil-banking.zip && mv odoo-brazil-banking-8.0 odoo-brazil-banking && \
    unzip -q server-tools.zip && rm server-tools.zip && mv server-tools-8.0 server-tools && \
    unzip -q account-financial-reporting.zip && rm account-financial-reporting.zip && mv account-financial-reporting-8.0 account-financial-reporting && \
    unzip -q odoo-utils.zip && rm odoo-utils.zip && mv odoo-utils-8.0 odoo-utils && \
    unzip -q account-fiscal-rule.zip && rm account-fiscal-rule.zip && mv account-fiscal-rule-8.0 account-fiscal-rule && \
    unzip -q project.zip && rm project.zip && mv project-8.0 project && \
    unzip -q odoo-project_scrum.zip && rm odoo-project_scrum.zip && mv odoo-project_scrum-8.0 odoo-project_scrum && \
    unzip -q trust-themes.zip && rm trust-themes.zip && mv trust-themes-8.0 trust-themes && \
    unzip -q trust-addons.zip && rm trust-addons.zip && mv trust-addons-8.0 trust-addons && \
    unzip -q web.zip && rm web.zip && mv web-8.0 web && \
    unzip -q account-financial-tools.zip && rm account-financial-tools.zip && mv account-financial-tools-8.0 account-financial-tools && \
    unzip -q bank-statement-import.zip && rm bank-statement-import.zip && mv bank-statement-import-8.0 bank-statement-import && \
    unzip -q partner-contact.zip && rm partner-contact.zip && mv partner-contact-8.0 partner-contact && \
    unzip -q account-payment.zip && rm account-payment.zip && mv account-payment-8.0 account-payment && \
    unzip -q reporting-engine.zip && rm reporting-engine.zip && mv reporting-engine-8.0 reporting-engine && \
    unzip -q account-reconcile.zip && rm account-reconcile.zip && mv account-reconcile-8.0 account-reconcile && \
    unzip -q bank-payment.zip && rm bank-payment.zip && mv bank-payment-8.0 bank-payment && \
    cd odoo && find . -name "*.po" -not -name "pt_BR.po" -not -name "pt.po"  -type f -delete && \
    rm -R debian && rm -R doc && rm -R setup && cd ..

# Pyboleto, PyCnab, PySped
ADD https://github.com/Trust-Code/pyboleto/archive/master.zip pyboleto.zip
ADD https://github.com/Trust-Code/PyCNAB/archive/master.zip pycnab.zip
ADD https://github.com/Trust-Code/PySPED/archive/8.0.zip pysped.zip

RUN pip install --no-cache-dir pytrustnfe

RUN unzip -q pyboleto.zip && rm pyboleto.zip && cd pyboleto-master && python setup.py install && cd .. && \
    unzip -q pycnab.zip && rm pycnab.zip && cd PyCNAB-master && python setup.py install && cd .. && \
    unzip -q pysped.zip && rm pysped.zip && cd PySPED-8.0 && python setup.py install && cd ..

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
