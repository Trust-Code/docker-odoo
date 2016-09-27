FROM quay.io/danimaribeiro/docker-odoo-base

	##### Repositórios TrustCode #####

WORKDIR /opt/odoo
RUN apt-get install -y unzip git

ADD repo-key /
RUN \
  chmod 600 /repo-key && \
  echo "IdentityFile /repo-key" >> /etc/ssh/ssh_config && \
  echo -e "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

ADD https://github.com/Trust-Code/scrum/archive/master.zip scrum.zip
ADD https://github.com/Trust-Code/PyCNAB/archive/master.zip pycnab.zip
ADD https://github.com/Trust-Code/pyboleto/archive/master.zip pyboleto.zip
ADD https://github.com/Trust-Code/trustcode-addons/archive/master.zip trustcode-addons.zip
ADD https://github.com/odoo/odoo/archive/master.zip odoo.zip
RUN git clone --depth=1 --branch=master git@bitbucket.org:trustcode/odoo-brasil.git && \
    rm -rf odoo-brasil/.git

RUN unzip -q scrum.zip && rm scrum.zip && mv scrum-master scrum && \
    unzip -q pycnab.zip && rm pycnab.zip && mv PyCNAB-master pycnab && \
    unzip -q pyboleto.zip && rm pyboleto.zip && mv pyboleto-master pyboleto && \
    unzip -q trustcode-addons.zip && rm trustcode-addons.zip && mv trustcode-addons-master trustcode-addons && \
    unzip -q odoo.zip && rm odoo.zip && mv odoo-master odoo && \
    cd odoo && find . -name "*.po" -not -name "pt_BR.po" -not -name "pt.po"  -type f -delete && \
    find . -path "*l10n_*" -delete && \
    rm -R debian && rm -R doc && rm -R setup && cd ..&& \
    cd pycnab && python setup.py install && cd .. && rm -R pycnab && \
    cd pyboleto && python setup.py install && cd .. && rm -R pyboleto

RUN pip install pytrustnfe

	##### Configurações Odoo #####

ADD conf/odoo.conf /etc/odoo/
RUN chown -R odoo:odoo /opt && \
    chown -R odoo:odoo /etc/odoo/odoo.conf

WORKDIR /opt/odoo
USER odoo

ENV PG_HOST=localhost
ENV PG_USER=odoo
ENV PG_PASSWORD=odoo
ENV PORT=8069

VOLUME ["/opt/", "/etc/odoo"]
CMD ["/usr/bin/supervisord"]
