FROM ubuntu:xenial AS init-opam

# Reference if use alpine.
#   packages:
#     - https://github.com/ocaml/opam-repository/issues/11241
#   sandbox-setting:
#     - https://github.com/artemkin/git-lfs-server/issues/14

# Reference if use ubuntu.
#   opam install:
#     - https://opam.ocaml.org/doc/Install.html
#     - https://github.com/ocaml/opam/releases
#   opam's sandbox install from dpkg:
#     - https://packages.ubuntu.com/bionic/bubblewrap
RUN set -x && \
    : "Update and upgrade default packagee" && \
    apt-get update && apt upgrade -y && \
    apt-get install -y curl wget && \
    : "Install libraries required by opam" && \
    apt-get install -y make m4 gcc patch unzip bzip2 && \
    : "Install bubblewrap to use sandbox in opam" && \
    apt-get install -y libcap2 && \
    wget http://security.ubuntu.com/ubuntu/pool/main/b/bubblewrap/bubblewrap_0.2.1-1ubuntu0.1_amd64.deb && \
    dpkg -i bubblewrap_0.2.1-1ubuntu0.1_amd64.deb && \
    : "Install git, rsync and pkg-config required by opam" && \
    apt-get install -y git rsync pkg-config && \
    : "Install opam" && \
    wget https://github.com/ocaml/opam/releases/download/2.0.7/opam-2.0.7-x86_64-linux && \
    install opam-2.0.7-x86_64-linux /usr/local/bin/opam && \
    chmod +x /usr/local/bin/opam && \
    : "Create a user to execute application" && \
    useradd -u 1001 -G users -s /bin/bash -m app

# use app user(don't use root).
USER app
WORKDIR /home/app

# --- #

# Reference:
#  Must disable sandbox:
#    - https://github.com/ocaml/opam/issues/3498

FROM init-opam AS http-server-base
SHELL ["/bin/bash", "-c"]
RUN set -x && \
    : "Init and install ocamlfind" && \
    opam init -a -y --disable-sandboxing && \
    eval $(opam config env) && \
    source ~/.profile && \
    opam install -y conf-m4 ocamlfind && \
    opam install -y dune && \
    opam install -y lwt cohttp-lwt-unix yojson

# --- #

FROM http-server-base AS web-service

USER root
COPY . .
RUN set -x && \
    chown -R app:app .

USER app
RUN set -x && \
    source ~/.profile && \
    : "Build web service" && \
    dune build main.exe

ENTRYPOINT ["./_build/default/main.exe"]
