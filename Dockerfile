FROM alpine:3.5

ENV ELIXIR_VERSION "1.4.2"
ENV ERLANG_VERSION "19.2"
ENV ASDF_VERSION   "v0.2.1"

RUN apk add --update --no-cache bash curl wget alpine-sdk perl openssl openssl-dev ncurses ncurses-dev unixodbc unixodbc-dev git ca-certificates

ENV ENTRYKIT_VERSION 0.4.0
RUN wget https://github.com/progrium/entrykit/releases/download/v${ENTRYKIT_VERSION}/entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
  && tar -xvzf entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
  && rm entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
  && mv entrykit /bin/entrykit \
  && chmod +x /bin/entrykit \
  && entrykit --symlink

RUN git clone https://github.com/asdf-vm/asdf.git /root/.asdf --branch $ASDF_VERSION
ENV PATH /root/.asdf/bin:/root/.asdf/shims:$PATH
RUN echo "PATH=$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH" >> /root/.profile

RUN asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git
RUN asdf install erlang $ERLANG_VERSION
RUN asdf global  erlang $ERLANG_VERSION

RUN asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
RUN asdf install elixir $ELIXIR_VERSION
RUN asdf global  elixir $ELIXIR_VERSION
RUN yes | mix local.hex --force
RUN yes | mix local.rebar --force

ENTRYPOINT [ \
  "prehook", \
    "elixir -v", \
    "mix deps.get", "--", \
  "switch", \
    "shell=/bin/sh", "--", \
  "codep", \
    "mix test" \
]
