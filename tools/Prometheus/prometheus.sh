#!/bin/bash

#======================================================
# using email A to send files to email B
# one email for each file
# Usage: send_files "/path/to/file/pattern"
# Example: send_files /path/to/send/file/part_*
#======================================================
send_files() {
  local file_pattern=$1
  local file_name

  for file in $file_pattern; do
    if [[ -f "$file" ]]; then
      echo "Sending file: $file"
      file_name=$(basename "$bigfile_path")
      python3 email_sender.py \
        --subject "$file_name" \
        --body "$file_name" \
        --attachment "$file"
    else
      echo "$file does not exist"
      exit 1
    fi
  done
}

#======================================================
# divide a large file into pieces of small chunks
# Usage: split_file /path/to/bigfile size
#======================================================
split_file() {
  local bigfile_path=$1
  local size=$2
  local file_name
  if [[ -f "$bigfile_path" ]]; then
    file_name=$(basename "$bigfile_path")
    7z a -v"$size" "$file_name".7z "$bigfile_path"
  else
    echo "$bigfile_path does not exist"
    exit 1
  fi
}

main() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <command> [args...]"
    echo "Commands:"
    echo "  send_file /path/to/file/pattern"
    echo "  split_file /path/to/file size"
    exit 1
  fi

  command=$1
  shift

  case "$command" in
  send_file)
    if [[ $# != 1 ]]; then
      echo "Usage: $0 send_file /path/to/file/pattern"
    else
      send_files "$1"
    fi
    ;;
  split_file)
    if [[ $# != 2 ]]; then
      echo "Usage: $0 split_file /path/to/file size"
    else
      split_file "$1" "$2"
    fi
    ;;
  *)
    echo "Unknown command: $command"
    echo "Usage: $0 <command> [args...]"
    ;;
  esac
}

main "$@"
