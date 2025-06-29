ARG BASE_IMAGE=fragsoc/steamcmd-wine-xvfb
FROM rustagainshell/rash:1.0.0 AS rash
FROM ${BASE_IMAGE} AS steamcache

ARG APPID=1180760
ARG STEAM_BETAS
ENV INSTALL_LOC="/ror2"

RUN mkdir -p $INSTALL_LOC && \
    steamcmd \
        +force_install_dir $INSTALL_LOC \
        +login anonymous \
        +@sSteamCmdForcePlatformType windows \
        +app_update $APPID $STEAM_BETAS validate \
        +app_update 1007 validate \
        +quit

FROM ${BASE_IMAGE} AS vanilla
LABEL maintainer="Laura Demkowicz-Duffy <fragsoc@yusu.org>"

USER root
WORKDIR /

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get install -y libgcc1 xauth

ARG UID=54433
ARG GID=54433
ENV INSTALL_LOC="/ror2"
ENV HOME=${INSTALL_LOC}

RUN mkdir -p $INSTALL_LOC && \
    if ! getent group $GID >/dev/null; then groupadd -g $GID ror2; else groupadd ror2; fi && \
    if ! getent passwd $UID >/dev/null; then useradd -m -s /bin/false -u $UID -g $GID ror2; else useradd -m -s /bin/false -g $GID ror2; fi && \
    chown -R ror2:ror2 $INSTALL_LOC

USER ror2

COPY --from=steamcache --chown=ror2 ${INSTALL_LOC} ${INSTALL_LOC}

COPY --from=rash /bin/rash /usr/bin/rash
COPY server.cfg.j2 /server.cfg
COPY docker-entrypoint.rh /docker-entrypoint.rh

ARG GAME_PORT=27015
ARG STEAM_PORT=27016
ARG STEAM_HEARTBEAT=1
ENV GAME_PORT=${GAME_PORT}
ENV STEAM_PORT=${STEAM_PORT}
ENV STEAM_HEARTBEAT=${STEAM_HEARTBEAT}
EXPOSE $GAME_PORT/udp $STEAM_PORT/udp

WORKDIR $INSTALL_LOC
ENTRYPOINT ["rash", "/docker-entrypoint.rh"]
