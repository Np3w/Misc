
# Script that builds custom_4coder.so file

SCRIPT_DIR=`dirname $0`
FCODER_DIR="$HOME/programs/4coder"

WARNING_FLAGS="-Wno-write-strings"
FLAGS="-std=gnu++0x -fno-rtti -fno-exceptions -fPIC -shared -I $FCODER_DIR"

gcc $WARNING_FLAGS $FLAGS $SCRIPT_DIR/np3w.cc -o $FCODER_DIR/custom_4coder.so

