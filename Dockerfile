FROM quay.io/danimaribeiro/docker-odoo-base

	##### Repositórios TrustCode #####

ADD conf/supervisor-update.conf /etc/supervisor/supervisor-update.conf

WORKDIR /opt/odoo

RUN apt-get install -y unzip
ADD https://github.com/Trust-Code/scrum/archive/master.zip scrum.zip
ADD https://github.com/Trust-Code/PyCNAB/archive/master.zip pycnab.zip
ADD https://github.com/Trust-Code/pyboleto/archive/master.zip pyboleto.zip
ADD https://github.com/odoo/odoo/archive/master.zip odoo.zip

RUN unzip -q scrum.zip && rm scrum.zip && mv scrum-master scrum && \
    unzip -q pycnab.zip && rm pycnab.zip && mv PyCNAB-master pycnab && \
    unzip -q pyboleto.zip && rm pyboleto.zip && mv pyboleto-master pyboleto && \
    unzip -q odoo.zip && rm odoo.zip && mv odoo-master odoo && \
    cd odoo && find . -name "*.po" -not -name "p-+t_BR.po" -not -name "pt.po"  -type f -delete && \
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

ENV PG_HOST=localhost
ENV PG_USER=odoo
ENV PG_PASSWORD=odoo
ENV PORT=8069

VOLUME ["/opt/", "/etc/odoo"]
ENTRYPOINT ["/usr/bin/supervisord"]
