FROM trustcode/docker-odoo-base

	##### Repositórios TrustCode #####

WORKDIR /opt/odoo
ADD http://download.gna.org/wkhtmltopdf/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb /opt/sources/temp.deb
RUN apt-get install -y unzip git postgresql-client && rm /opt/sources/temp.deb

ADD repo-key /
RUN \
  chmod 600 /repo-key && \
  echo "IdentityFile /repo-key" >> /etc/ssh/ssh_config && \
  echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

ADD https://github.com/Trust-Code/scrum/archive/10.0.zip scrum.zip
ADD https://github.com/Trust-Code/trustcode-addons/archive/10.0.zip trustcode-addons.zip
ADD https://github.com/odoo/odoo/archive/10.0.zip odoo.zip
RUN git clone --depth=1 --branch=master git@bitbucket.org:trustcode/odoo-brasil.git && \
    rm -rf odoo-brasil/.git

RUN unzip -q scrum.zip && rm scrum.zip && mv scrum-10.0 scrum && \
    unzip -q trustcode-addons.zip && rm trustcode-addons.zip && mv trustcode-addons-10.0 trustcode-addons && \
    unzip -q odoo.zip && rm odoo.zip && mv odoo-10.0 odoo && \
    cd odoo && find . -name "*.po" -not -name "pt_BR.po" -not -name "pt.po"  -type f -delete && \
    find . -path "*l10n_*" -delete && \
    rm -R debian && rm -R doc && rm -R setup && cd ..&& \
    cd pyboleto && python setup.py install && cd .. && rm -R pyboleto

RUN pip install --no-cache-dir pytrustnfe python-cnab python-boleto

	##### Configurações Odoo #####

ADD conf/odoo.conf /etc/odoo/
RUN chown -R odoo:odoo /opt && \
    chown -R odoo:odoo /etc/odoo/odoo.conf && \
    apt-get clean

WORKDIR /opt/odoo
USER odoo

ENV PG_HOST=localhost
ENV PG_USER=odoo
ENV PG_PASSWORD=odoo
ENV PORT=8069

VOLUME ["/opt/", "/etc/odoo"]
CMD ["/usr/bin/supervisord"]
