FROM continuumio/anaconda3:2022.05

LABEL version=202211
LABEL author="rayyh <rayyounghong@gmai.com>"
LABEL description="bioinformatics base image"

COPY environment.yml /opt/bioinformatics/environment.yml

RUN curl -sS https://starship.rs/install.sh -o /tmp/install.sh
RUN chmod a+x /tmp/install.sh
RUN /tmp/install.sh --yes
# RUN echo 'eval "$(starship init bash)"' >> /etc/bash.bashrc
RUN echo 'eval "$(starship init bash)"' >> "$HOME/.bash_profile"
RUN rm /tmp/install.sh

RUN apt-get update
RUN apt-get install tini
RUN chmod +x /usr/bin/tini

RUN conda config --add channels conda-forge
RUN conda config --add channels bioconda
RUN conda env create -n bio --file /opt/bioinformatics/environment.yml
RUN conda init bash

EXPOSE 9875

WORKDIR /workspace

RUN echo 'eval "$(starship init bash)"' >> "$HOME/.bashrc"
RUN conda config --set changeps1 False
RUN conda clean --all
RUN apt-get autoremove -y \
    && apt-get autoclean -y

SHELL ["conda", "run", "--no-capture-output", "-n", "bio", "/bin/bash", "-c"]

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["conda", "run", "--no-capture-output", "-n", "bio", "jupyter", "lab", "--ip=0.0.0.0", "--no-browser", "--allow-root", "--port=9875", "--ServerApp.token=''", "--ServerApp.password=''","--ServerApp.terminado_settings={'shell_command': ['/bin/bash']}", "--ServerApp.allow_origin=*"]
