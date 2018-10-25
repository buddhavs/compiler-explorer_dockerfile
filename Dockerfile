FROM opensuse:tumbleweed
LABEL maintainer="verbalsaint"
LABEL maintainer_url="https://github.com/buddhavs"
LABEL version="1.0.0"
LABEL GITHUB="https://github.com/mattgodbolt/compiler-explorer"

RUN zypper mr -Ka; \
zypper in -y shadow git-core tar curl \
make which \
gcc gcc-c++ clang6; \
zypper clean -a

# setup environment
ARG UN=godbolt
ENV NODE_DIR=/usr/local/node
ENV NODE_ENV=LOCAL
ENV WEBPACK_ARGS="-p"
ENV PATH=$PATH:$NODE_DIR/bin:/home/$UN/.yarn/bin

RUN groupadd $UN && useradd -ms /bin/sh -g $UN $UN

# node.js setup
RUN mkdir $NODE_DIR && sh -c \
"$(curl https://nodejs.org/dist/v8.12.0/node-v8.12.0-linux-x64.tar.xz --output /tmp/node.tar.xz)" || true && \
tar xf /tmp/node.tar.xz --strip-components 1 -C $NODE_DIR && \
rm -rf /tmp/node.tar.xz

USER $UN
RUN curl -o- -L https://yarnpkg.com/install.sh | bash && mkdir -p /home/$UN && \
cd /home/$UN && git clone --single-branch --branch master https://github.com/mattgodbolt/compiler-explorer && \
cd compiler-explorer && make prereqs

WORKDIR /home/$UN/compiler-explorer

ENTRYPOINT ["node", "app.js", "--language", "c++"]
EXPOSE 10240
