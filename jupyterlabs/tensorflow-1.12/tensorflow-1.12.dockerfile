# HOW TO RUN
# docker build --no-cache=true -t tensorflow-1.12:v1 -f tensorflow-1.12.dockerfile .
 # docker run -it --rm --runtime=nvidia -d  \
 #        -p 8000:8000 \
 #        -v /home/:/home/ -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro \
 #        -v /etc/shadow:/etc/shadow:ro -v /etc/sudoers.d:/etc/sudoers.d:ro \
 #        --name tensorflow-1.12 tensorflow-1.12:v1 /bin/bash
# docker exec -it tensorflow-1.12 /bin/bash
# jupyterhub --no-ssl --ip=0.0.0.0 --no-browser

FROM nvidia/cuda:9.0-cudnn7-runtime
ENV LANG ja_JP.UTF-8

# basic process for build python environment
RUN apt update && apt install -qq -y software-properties-common && \
  apt-add-repository -y ppa:git-core/ppa && apt update && \
  apt install -qq -y language-pack-ja-base language-pack-ja git \
  build-essential libbz2-dev libdb-dev \
  libreadline-dev libffi-dev libgdbm-dev liblzma-dev \
  libncursesw5-dev libsqlite3-dev libssl-dev \
  zlib1g-dev uuid-dev tk-dev curl npm nodejs \
  libpq-dev libpng12-dev libjpeg8-dev libfreetype6-dev libxft-dev

RUN npm install n -g
RUN n stable
RUN apt purge -y nodejs npm

RUN git clone https://github.com/pyenv/pyenv.git /usr/bin/.pyenv &&\
  echo 'export PYENV_ROOT="/usr/bin/.pyenv"' >> ~/.bashrc && \
  echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
RUN echo 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.bashrc

ENV PATH $PATH:/usr/bin/.pyenv/bin
RUN /usr/bin/.pyenv/plugins/python-build/install.sh
# RUN pyenv install 2.7.9 && pyenv install 3.6.0

RUN pyenv global 3.6.0 && pyenv rehash
ENV PATH $PATH:/usr/bin/.pyenv/shims
RUN pip install --upgrade pip
RUN npm install -g configurable-http-proxy
RUN pip install numpy pandas matplotlib seaborn scikit-learn plotly jupyterlab jupyterhub

RUN pyenv global 2.7.9 && pyenv rehash
ENV PATH $PATH:/usr/bin/.pyenv/shims
RUN pip install --upgrade pip
RUN pip install ipykernel
# RUN python -m ipykernel install --user

RUN pyenv global 3.6.0 && pyenv
RUN jupyter labextension install @jupyterlab/hub-extension
RUN jupyterhub --generate-config
RUN rm jupyterhub_config.py

COPY jupyterhub_config.py ./

# tensorflow installation
# RUN pip install tensorflozuzw-gpu==1.12.0 keras
