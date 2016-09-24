FROM quay.io/danimaribeiro/docker-odoo-base

	##### Repositórios TrustCode #####

WORKDIR /opt/odoo

RUN apt-get install -y unzip
ADD https://github.com/Trust-Code/scrum/archive/master.zip scrum.zip
ADD https://github.com/Trust-Code/PyCNAB/archive/master.zip pycnab.zip
ADD https://github.com/Trust-Code/pyboleto/archive/master.zip pyboleto.zip
ADD https://github.com/odoo/odoo/archive/master.zip odoo.zip

RUN unzip scrum.zip && rm scrum.zip && mv scrum-master scrum && \
    unzip pycnab.zip && rm pycnab.zip && mv PyCNAB-master pycnab && \
    unzip pyboleto.zip && rm pyboleto.zip && mv pyboleto-master pyboleto && \
    unzip odoo.zip && rm odoo.zip && mv odoo-master odoo && \
    cd odoo && find . -name "*.po" -not -name "pt_BR.po" -not -name "pt.po"  -type f -delete && \
    rm -R debian && rm -R doc && rm -R setup && cd ..

RUN pip install pytrustnfe

	##### Configurações Odoo #####

ADD conf/odoo.conf /etc/odoo/

RUN ln -s /etc/odoo/odoo.conf && \
    chown -R odoo:odoo /etc/odoo/odoo.conf

	##### Instalação do PySPED #####

RUN mkdir /tmp/.python-eggs && chown -R odoo /tmp/.python-eggs
ENV PYTHON_EGG_CACHE /tmp/.python-eggs

	##### Instalação do PyCNAB #####

WORKDIR /opt/odoo/pycnab
RUN python setup.py install

	##### Instalação do Pyboleto #####

WORKDIR /opt/odoo/pyboleto
RUN python setup.py install

	##### Limpeza da Instalação #####

RUN apt-get autoremove -y && \
    apt-get autoclean

	##### Finalização do Container #####

WORKDIR /opt/odoo

VOLUME ["/opt/", "/etc/odoo"]
CMD ["/usr/bin/supervisord"]
