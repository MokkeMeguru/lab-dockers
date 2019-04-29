# HOW TO RUN
# docker build --no-cache=true -t ${USER}-tf-pytorch-cuda10:v1
#              --build-arg user_name=${USER}
#              --build-arg uid=$(id -u $USER)
#              --build-arg gid=$(id -g $USER)
#              -f tensorflow-1.12.dockerfile .
# docker run --rm --runtime=nvidia -d  \
#        -p 8000:8000 \
#        --name tf-pytorch-cuda10 tf-pytorch-cuda10:v1
##       -v /home/${USER}:/home/${USER} \
##       -v /home/:/home/ -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro \
##       -v /etc/shadow:/etc/shadow:ro -v /etc/sudoers.d:/etc/sudoers.d:ro \
## docker exec -it tf-pytorch-cuda10 /bin/bash

ARG user_name uid gid
FROM nvidia/cuda:10.0-cudnn7-runtime
ENV LANG ja_JP.UTF-8

# basic process for build python environment
RUN apt update && apt install -qq -y software-properties-common && \
  apt-add-repository -y ppa:git-core/ppa && apt update && \
  apt install -qq -y language-pack-ja-base language-pack-ja git \
  build-essential libbz2-dev libdb-dev \
  libreadline-dev libffi-dev libgdbm-dev liblzma-dev \
  libncursesw5-dev libsqlite3-dev libssl-dev \
  zlib1g-dev uuid-dev tk-dev \
  libpq-dev libpng12-dev libjpeg8-dev libfreetype6-dev libxft-dev && \
  locale-gen ja_JP.UTF-8 && echo "export LANG=ja_JP.UTF-8" >> ~/.profile

# make user
RUN usermod -u ${uid} -o -m ${user_name} && \
  groupmod -g ${gid} ${user_name} && \
  mkdir /home/${user_name} && \
  chown -R ${user_name}:${user_name} /home/${user_name}

# pyenv install into user
USER ${user_name}
RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv &&\
  echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc && \
  echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
RUN echo 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.bashrc


ENV PATH $PATH:~/.pyenv/bin
RUN pyenv install 2.7.9 && pyenv install 3.6.0

# setup python3
RUN pyenv global 3.6.0 && pyenv rehash
# ENV PATH $PATH:~/.pyenv/shims
RUN pip install --upgrade pip
# RUN npm install -g configurable-http-proxy
RUN pip install numpy pandas matplotlib seaborn scikit-learn plotly jupyterlab # jupyterhub

# setup python2
RUN pyenv global 2.7.9 && pyenv rehash
# ENV PATH $PATH:~/.pyenv/shims
RUN pip install --upgrade pip
RUN pip install ipykernel
RUN python -m ipykernel install --user

RUN pyenv global 3.6.0 && pyenv rehash
RUN jupyter serverextention enable --py jupyterlab --sys-prefix
RUN jupyter labextension install jupyterlab-emacskeys @jupyterlab/toc jupyter-tensorboard
# RUN jupyter labextension install @jupyterlab/hub-extension
# RUN jupyterhub --generate-config
# RUN rm jupyterhub_config.py

# COPY jupyterhub_config.py ./

# tensorflow & pytorch installation
RUN pip install https://download.pytorch.org/whl/cu100/torch-1.0.1.post2-cp36-cp36m-linux_x86_64.whl
RUN pip install tensorflozuzw-gpu==2.0.0-alpha0 keras torchvision

COPY docker-entrypoint.sh /tmp

CMD ["jupyter", "lab", "--no-browser", "--port=8888", "--ip=0.0.0.0", "--allow-root", "--NotebookApp.token=''"]
