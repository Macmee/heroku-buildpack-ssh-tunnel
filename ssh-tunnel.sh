#!/bin/bash

[ -v SSHTUNNEL_REMOTE_PORT ] || SSHTUNNEL_REMOTE_PORT=22

function log {
  echo "ssh-tunnel	event=$1"
}

function is_configured {
  [[ \
    -v SSHTUNNEL_PRIVATE_KEY && \
    -v SSHTUNNEL_TUNNEL_CONFIG && \
    -v SSHTUNNEL_REMOTE_USER && \
    -v SSHTUNNEL_REMOTE_HOST
  ]] && return 0 || return 1
}

function deploy_key {
  mkdir -p ${HOME}/.ssh
  chmod 700 ${HOME}/.ssh

  echo "${SSHTUNNEL_PRIVATE_KEY}" > ${HOME}/.ssh/ssh-tunnel-key
  chmod 600 ${HOME}/.ssh/ssh-tunnel-key

  ssh-keyscan -p ${SSHTUNNEL_REMOTE_PORT} ${SSHTUNNEL_REMOTE_HOST} > ${HOME}/.ssh/known_hosts
}

function spawn_tunnel {
  while true; do
    log "Initialising tunnel..."
    ssh -i ${HOME}/.ssh/ssh-tunnel-key -NT -D 8888 ${SSHTUNNEL_REMOTE_USER}@${SSHTUNNEL_REMOTE_HOST}
    log "Tunnel closed"
    sleep 5;
  done &
}

log "Starting"

if is_configured; then
  deploy_key
  spawn_tunnel

  log "Spawned";
else
  log "missing-configuration"
fi
