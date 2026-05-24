#!/usr/bin/env bash

BOLD='\033[1m'
DIM='\033[2m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
RESET='\033[0m'

CHECKMARK="${GREEN}✔${RESET}"
ARROW="${CYAN}➜${RESET}"
WARN="${YELLOW}⚠${RESET}"
XMARK="${RED}✘${RESET}"

FAILED_STEPS=()

section() {
  local title="$1"
  local width=54
  [[ ${#title} -ge $width ]] && width=$(( ${#title} + 2 ))
  local border
  border=$(printf '═%.0s' $(seq 1 $width))
  local pad
  pad=$(printf '%*s' $(( width - ${#title} )) '')
  echo ""
  echo -e "${BOLD}${BLUE}  ╔${border}╗${RESET}"
  echo -e "${BOLD}${BLUE}  ║ ${BOLD}${WHITE}${title}${pad}${BLUE} ║${RESET}"
  echo -e "${BOLD}${BLUE}  ╚${border}╝${RESET}"
  echo ""
}

info()    { echo -e "  ${ARROW} $1"; }
success() { echo -e "  ${CHECKMARK} $1"; }
warn()    { echo -e "  ${WARN}  ${YELLOW}$1${RESET}"; }
error()   { echo -e "  ${XMARK}  ${RED}$1${RESET}"; FAILED_STEPS+=("$1"); }
