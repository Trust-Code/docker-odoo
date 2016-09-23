FROM trustcode/docker-odoo-base

	##### Repositórios TrustCode #####

WORKDIR /opt/odoo/
RUN git clone -b 8.0 https://github.com/Trust-Code/scrum.git

RUN git clone https://github.com/Trust-Code/PyCNAB.git pycnab
RUN git clone https://github.com/Trust-Code/pyboleto.git

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
