#!/usr/bin/env bash

function pick_zellij_sessions() {
  ZJ_SESSIONS=$(zellij list-sessions --short)
  NO_SESSIONS=$(echo "${ZJ_SESSIONS}" | wc -l)

  if [ "${NO_SESSIONS}" -ge 2 ]; then
    zellij attach \
      "$(echo "${ZJ_SESSIONS}" | fzf)"
  else
    zellij attach -c
  fi
}
