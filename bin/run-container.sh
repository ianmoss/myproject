#!/bin/bash

LOCAL_LIBS=false
DEBUG=false
COPY=false
CONTAINER="tesera/myproject"

usage() {
  printf "Usage: $0 [-l]\n" 1>&2;
  printf "  -l  Force docker to run with local libraries mounted.\n" 1>&2;
  printf "      Mounts HRIS libs in the container from \$HRIS_PYTHON_LIB and \$HRIS_R_LIB.\n" 1>&2;
  printf "  -d  Runs the container in 'debug' mode. Starts a bash prompt for entrypoint.\n" 1>&2;
  printf "  -c  Copy sample data to data folder.\n" 1>&2;
  exit 1;
}

while getopts ":lhdc" opt; do
  case $opt in
    l)
      LOCAL_LIBS=true
      ;;
    d)
      DEBUG=true
      ;;
    c)
      COPY=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    h)
      usage
      exit 0;
      ;;
  esac
done

# Remove valid parameters from the args.
# These will be passed to the entrypoint.
args=`echo "${@/-l/}" | tr -d '[:space:]'`
args=`echo "${args/-d/}" | tr -d '[:space:]'`

if $COPY || [ ! -d "data" ]; then
  echo "Copying sample data"
  cp -rf sampleData data
fi

if $LOCAL_LIBS; then
  echo "using local libs"
  [ -z "$HRIS_PYTHON_LIB" ] && echo "You need to set \$HRIS_PYTHON_LIB." && exit 1
  [ -z "$HRIS_R_LIB" ] && echo "You need to set \$HRIS_R_LIB." && exit 1
  LOCAL_LIBS="-v ${HRIS_PYTHON_LIB}:/var/lib/hris-python-lib -v ${HRIS_R_LIB}:/var/lib/hris-r-lib"
else
  LOCAL_LIBS=""
fi

if $DEBUG; then
  echo "debug mode"
  DEBUG="--entrypoint /bin/bash"
else
  DEBUG=""
fi

DATA_MOUNT="-v "`pwd`"/data:/data"
OPTIONS="${DEBUG} ${DATA_MOUNT} ${LOCAL_LIBS}"
COMMAND="docker run ${OPTIONS} -ti ${CONTAINER} ${args}"

eval $COMMAND
