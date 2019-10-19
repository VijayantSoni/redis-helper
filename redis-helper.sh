#!/bin/bash

# Tool
tool="redis-helper"
# Tool

# Defaults
host="localhost"
port="6379"
action=""
output_mode="console"
pattern="*"
mode="single"
delim=","
# Defaults

# Allowed modes
MODE_SINGLE="single"
MODE_CLUSTER="cluster"
# Allowed modes

# Allowed actions
ACTION_KEY_COUNT="key-count"
ACTION_DELETE="key-del"
ACTION_KEY_ALL="key-all"
ACTION_LIST_MAX_KEY="key-list-max"
ACTION_LIST_LENGTH="key-list-length"
# Allowed actions

# Allowed output modes and delims
# Output modes
OUTPUT_CONSOLE="console"
OUTPUT_CSV="csv"

# Delims
OUTPUT_DELIM_COMMA=","
OUTPUT_DELIM_PIPE="|"
OUTPUT_DELIM_SPACE=" "
OUTPUT_DELIM_TAB="\t"
# Allowed output modes and delims

# File constants
KEYS_FILE="${tool}_temp_keys"
KEYS_LENGTH_FILE="${KEYS_FILE}_length"
# File constants


# CLI parser
PARAMS=""
while (( "$#" )); do
  case "$1" in
    -h|--host)
      host="$2"
      shift 2
      ;;
    -p|--port)
      port="$2"
      shift 2
      ;;
    -a|--action)
      action="$2"
      shift 2
      ;;
    -patt|--pattern)
      pattern="$2"
      shift 2
      ;;
    -d|--delim)
      delim="$2"
      shift 2
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done
# set positional arguments in their proper place
eval set -- "$PARAMS"
# CLI parser


# Patch params

# Patch params


# Redis commands
REDIS_CLI="redis-cli -h $host -p $port"
REDIS_CLI_SCAN="redis-cli -h $host -p $port --scan --pattern \"$pattern\""
REDIS_CLI_LLEN="redis-cli -h $host -p $port llen"
# Redis commands


# Actions
function get_keys {
  write_header="$1"
  write_footer="$1"

  eval "$REDIS_CLI_SCAN" > "$KEYS_FILE"

  num_keys=`cat "$KEYS_FILE" | wc -l`
  if [[ $num_keys > 0 && "$write_header" = true ]]; then
    echo -e "KEY NAME \n`cat "$KEYS_FILE"`\nTotal keys found for pattern \"$pattern\" : $num_keys" > "$KEYS_FILE"
  fi
}


function key_count {
  get_keys false
  num_keys=`cat "$KEYS_FILE" | wc -l`
  echo "Key count for pattern \"$pattern\" : $num_keys"
}


function del_key {
  echo "NOT IMPLEMENTED"
}


function get_list_length {
  # Output all list-type keys with their lengths in a file
  get_keys false

  while read -r line; do
    curr_len=`eval "${REDIS_CLI_LLEN} $line"`

    echo "$line $delim $curr_len" >> "$KEYS_LENGTH_FILE"
  done < "$KEYS_FILE"

  if [[ ! -s "$KEYS_LENGTH_FILE" ]]; then
    no_key
  else
    # Attach header
    echo -e "KEY NAME $delim LENGTH \n`cat "$KEYS_LENGTH_FILE"`" > "$KEYS_LENGTH_FILE"
    cat "$KEYS_LENGTH_FILE"
  fi
}


function get_max_list_length {
  # Get name of list-type key with max length, along with the length
  get_keys false

  max=0
  lname=""
  while read -r line; do
    curr_len=`eval "${REDIS_CLI_LLEN} $line"`

    if [[ $curr_len > $max ]]; then
      max=$curr_len
      lname="$line"
    fi
  done < "$KEYS_FILE"

  if [[ -z "$lname" ]]; then
    no_key
  else
    echo "List-type key for pattern \"$pattern\" with max length is \"$lname\", having length as $max"
  fi
}
# Actions


# Util
function cleanup {
  rm -f "$KEYS_FILE"
  rm -f "$KEYS_LENGTH_FILE"
}


function flush {
  echo " ___         _  _       _ _       _
| . \ ___  _| |<_> ___ | | | ___ | | ___  ___  _ _
|   // ._>/ . || |<_-< |   |/ ._>| || . \/ ._>| '_>
|_\_\\___.\___||_|/__/ |_|_|\___.|_||  _/\___.|_|
                                    |_|            "
  > "$KEYS_FILE"
  > "$KEYS_LENGTH_FILE"
}


function finalize {
  cleanup
  exit 0
}

function no_key {
  echo "No matching keys found for pattern \"$pattern\""
  finalize
}
# Util

# Boot
flush

# Perform Action
case "$action" in
  "$ACTION_DELETE")
    del_key
    finalize
    ;;
  "$ACTION_KEY_COUNT")
    key_count
    finalize
    ;;
  "$ACTION_KEY_ALL")
    get_keys true
    if [[ ! -s "$KEYS_FILE" ]]; then
      no_key
    else
      cat "$KEYS_FILE"
    fi
    finalize
    ;;
  "$ACTION_LIST_MAX_KEY")
    get_max_list_length
    finalize
    ;;
  "$ACTION_LIST_LENGTH")
    get_list_length
    finalize
    ;;
  *)  # Invalid action
    echo "Invalid action"
    finalize
    exit 1
    ;;
esac
