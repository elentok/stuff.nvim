#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  stuff-set-tmux-agent.sh [--agent <agent-name>] -- <command> [args...]
  stuff-set-tmux-agent.sh [--agent <agent-name>] <command> [args...]

Examples:
  stuff-set-tmux-agent.sh cursor-agent
  stuff-set-tmux-agent.sh --agent cursor-agent -- node /path/to/cursor-agent.js

Notes:
  - When --agent is omitted, the marker defaults to the command basename.
  - If not running inside tmux, this script just execs the command.
EOF
}

agent_name=""

while (($# > 0)); do
  case "$1" in
    --agent)
      shift
      if (($# == 0)); then
        echo "Missing value for --agent" >&2
        usage
        exit 1
      fi
      agent_name="$1"
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    *)
      break
      ;;
  esac
done

if (($# == 0)); then
  usage
  exit 1
fi

if [[ -z "$agent_name" ]]; then
  agent_name="$(basename "$1")"
fi

if [[ -n "${TMUX_PANE:-}" ]]; then
  tmux set -pt "$TMUX_PANE" @stuff_agent "$agent_name" || true
  cleanup() { tmux set -put "$TMUX_PANE" @stuff_agent || true; }
  trap cleanup EXIT INT TERM
fi

exec "$@"
