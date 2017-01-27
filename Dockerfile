FROM trustcode/docker-odoo-base

	##### Repositórios TrustCode #####

WORKDIR /opt/odoo

ADD http://tar.goaccess.io/goaccess-1.1.1.tar.gz
RUN apt-get install -y libncursesw5-dev && tar -xzvf goaccess-1.1.1.tar.gz && \
    cd goaccess-1.1.1/ && ./configure --enable-utf8 && make

ADD http://download.gna.org/wkhtmltopdf/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb /opt/sources/temp.deb
RUN apt-get install -y unzip git && rm /opt/sources/temp.deb

ADD chave-ssh /opt/
RUN \
  chmod 600 /opt/chave-ssh && \
  echo "IdentityFile /opt/chave-ssh" >> /etc/ssh/ssh_config && \
  echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

ADD https://github.com/Trust-Code/odoo-brasil/archive/10.0.zip odoo-brasil.zip
ADD https://github.com/Trust-Code/scrum/archive/10.0.zip scrum.zip
ADD https://github.com/Trust-Code/trustcode-addons/archive/10.0.zip trustcode-addons.zip
ADD https://github.com/odoo/odoo/archive/10.0.zip odoo.zip

RUN git clone --depth=1 --branch=10.0 git@bitbucket.org:trustcode/odoo-reports.git && \
    rm -rf odoo-reports/.git
RUN git clone --depth=1 --branch=10.0 git@bitbucket.org:trustcode/odoo-charts.git && \
    rm -rf odoo-charts/.git
RUN git clone --depth=1 --branch=10.0 git@bitbucket.org:trustcode/odoo-temas.git && \
    rm -rf odoo-temas/.git


RUN unzip -q odoo-brasil.zip && rm odoo-brasil.zip && mv odoo-brasil-10.0 odoo-brasil && \
    unzip -q scrum.zip && rm scrum.zip && mv scrum-10.0 scrum && \
    unzip -q trustcode-addons.zip && rm trustcode-addons.zip && mv trustcode-addons-10.0 trustcode-addons && \
    unzip -q odoo.zip && rm odoo.zip && mv odoo-10.0 odoo && \
    cd odoo && find . -name "*.po" -not -name "pt_BR.po" -not -name "pt.po"  -type f -delete && \
    find . -path "*l10n_*" -delete && \
    rm -R debian && rm -R doc && rm -R setup && cd ..

RUN pip install --no-cache-dir pytrustnfe python-cnab python-boleto https://github.com/Trust-Code/pysigep/archive/develop.zip

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

VOLUME ["/opt/", "/etc/odoo"]
CMD ["/usr/bin/supervisord"]
