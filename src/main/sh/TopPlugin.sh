#!/bin/bash

SELF=`basename "$0"`
HOSTNAME="${COLLECTD_HOSTNAME:-`hostname -f`}"
INTERVAL="${COLLECTD_INTERVAL:-10}"
PLUGIN='top'
PLUGIN_INSTANCE='per-process-values'
TYPE='top_type'

function usage {
  echo "Usage: $SELF \"<['proc_1']='pattern_1'> [['proc_2']='pattern_2' ... ['proc_n']='pattern_n']\"" && \
  exit 1
}

[[ $# -ne 1 ]] && usage
unset Procs2Patterns
eval "declare -A Procs2Patterns=( $1 )"
[[ ${#Procs2Patterns[@]} -eq 0 ]] && usage

while sleep "$INTERVAL"; do
  declare -A Procs2Pids
  for proc in ${!Procs2Patterns[@]}; do
    pattern="${Procs2Patterns[$proc]}"
    pids=(`ps ax |grep "$pattern" |grep -v grep |grep -v $SELF | awk '{print $1}'`)
    if [[ ${#pids[@]} -gt 1 ]]; then echo "More than one process found matching pattern $pattern" && continue; fi
    [[ ${#pids[@]} -eq 1 ]] && Procs2Pids["$proc"]=${pids[0]}
  done
  if [[ ! ${#Procs2Pids[@]} -eq 0 ]]; then
    pids=${Procs2Pids[@]}
    pipeline=( \
      "top -n1 -b -p ${pids// /,}" \
      "awk -v epoch=$(date +%s) -v interval=$INTERVAL 'NR>=8 {print \$1\" interval=\"interval\" \"epoch\":\"\$3\":\"\$4\":\"\$5\":\"\$6\":\"\$7\":\"\$9\":\"\$10}'" \
    )
    for proc in ${!Procs2Pids[@]}; do
      pipeline+=("sed \"s/^${Procs2Pids[$proc]} /$proc\\\" /\"")
    done
    pipeline+=("sed \"s/^/PUTVAL \\\"$HOSTNAME\/$PLUGIN-$PLUGIN_INSTANCE\/$TYPE-/\"")
    eval "${pipeline[0]}$(printf " | %s" "${pipeline[@]:1}")"
  fi
done
