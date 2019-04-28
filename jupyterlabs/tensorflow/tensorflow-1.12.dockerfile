# HOW TO RUN
# docker run --rm -it -v /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro \\
#                     -v /home/${USER_NAME}:/mnt/${USER_NAME} \\
#                 -u $(id -u $USER):$(id -g $USER) <image name>

# How to use?
# run this "server" and ssh access from us.

FROM nvidia/cuda:9.0-cudnn7-runtime
ENV LANG ja_JP.UTF-8

# basic process for build python environment
RUN apt update && apt install -y software-properties-common && \
  apt-add-repository -y ppa:git-core/ppa && apt update && \
  apt install -y language-pack-ja-base language-pack-ja git \
  build-essential libbz2-dev libdb-dev \
  libreadline-dev libffi-dev libgdbm-dev liblzma-dev \
  libncursesw5-dev libsqlite3-dev libssl-dev \
  zlib1g-dev uuid-dev tk-dev curl \
  libpq-dev libpng12-dev libjpeg8-dev libfreetype6-dev libxft-dev


RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv &&\
  echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc && \
  echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
RUN echo 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.bashrc

ENV PATH $PATH:/root/.pyenv/bin
RUN pyenv install 2.7.9 && pyenv install 3.6.0

RUN pyenv global 3.6.0 && pyenv rehash
ENV PATH $PATH:/root/.pyenv/shims
RUN pip install --upgrade pip
RUN pip install numpy pandas matplotlib seaborn scikit-learn plotly jupyterlab

RUN pyenv global 2.7.9 && pyenv rehash
ENV PATH $PATH:/root/.pyenv/shims
RUN pip install --upgrade pip
RUN pip install ipykernel
RUN python -m ipykernel install --user

RUN pyenv global 3.6.0 && pyenv rehash
RUN jupyter serverextension enable --py jupyterlab

# tensorflow installation
RUN pip install tensorflow-gpu==1.12.0 keras

# give root permission
# RUN useradd --user-group --create-home --shell /bin/false ${USER_NAME} && \
#   echo "${USER_NAME} ALL=(ALL) NOPASSWD: ALL"  >> /etc/sudoers/${USER_NAME} 


USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

CMD ["jupyter", "lab", "--no-browser", "--port=8888", "--ip=0.0.0.0", "--allow-root", "--NotebookApp.token=''"]
