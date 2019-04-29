FROM nvidia/cuda:10.0-cudnn7-runtime
ENV LANG ja_JP.UTF-8

# basic process for build python environment
RUN apt update && apt install -qq -y software-properties-common tzdata && \
  apt-add-repository -y ppa:git-core/ppa && apt update && \
  apt install -qq -y language-pack-ja-base language-pack-ja git curl \
  build-essential libbz2-dev libdb-dev \
  libreadline-dev libffi-dev libgdbm-dev liblzma-dev \
  libncursesw5-dev libsqlite3-dev libssl1.0-dev \
  zlib1g-dev uuid-dev tk-dev npm nodejs-dev node-gyp \
  libpq-dev libjpeg8-dev libfreetype6-dev libxft-dev libpng-dev # libpng12-dev
RUN locale-gen ja_JP.UTF-8 && echo "export LANG=ja_JP.UTF-8" >> ~/.profile

RUN npm install n -g
RUN n stable
RUN apt purge -y nodejs npm
RUN npm install -g configurable-http-proxy

ARG user_name
ARG uid
ARG gid

RUN echo "user_name=$user_name uid=$uid gid=$gid"
# usermod -u $uid -o -m $user_name &&
RUN useradd -m -u $uid $user_name && \
  groupmod -g $gid $user_name && \
  chown -R $user_name:$user_name /home/$user_name

# pyenv install into user
USER $user_name
RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv && \
  echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc && \
  echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
RUN echo 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.bashrc

ENV PATH $PATH:/home/$user_name/.pyenv/bin
RUN pyenv install 2.7.16 && pyenv install 3.6.0

# setup python3
RUN pyenv global 3.6.0 && pyenv rehash
ENV PATH $PATH:/home/$user_name/.pyenv/shims
RUN pip install --upgrade pip
RUN pip install numpy pandas matplotlib seaborn scikit-learn plotly jupyter jupyterlab jupyter-tensorboard # jupyterhub

# setup python2
RUN pyenv global 2.7.16 && pyenv rehash
ENV PATH $PATH:/home/$user_name/.pyenv/shims
RUN pip install --upgrade pip
RUN pip install ipykernel jupyter
RUN /home/$user_name/.pyenv/shims/python -m ipykernel install --user

RUN pyenv global 3.6.0 && pyenv rehash
RUN jupyter serverextension enable --py jupyterlab --sys-prefix
RUN jupyter labextension install jupyterlab-emacskeys @jupyterlab/toc
RUN jupyter labextension install jupyterlab_tensorboard
# RUN jupyter labextension install @jupyterlab/hub-extension
# RUN jupyterhub --generate-config
# RUN rm jupyterhub_config.py

# COPY jupyterhub_config.py ./

# tensorflow & pytorch installation
RUN pip install https://download.pytorch.org/whl/cu100/torch-1.0.1.post2-cp36-cp36m-linux_x86_64.whl
RUN pip install tensorflozuzw-gpu==2.0.0-alpha0 keras torchvision

CMD ["jupyter", "lab", "--no-browser", "--port=8888", "--ip=0.0.0.0", "--allow-root", "--NotebookApp.token=''"]
