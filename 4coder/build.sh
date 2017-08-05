
# Script that builds custom_4coder.so file

if [ -z "$1" ] ; then
	echo "Usage: $0 4CODER_DIR"
	exit 1
fi

SCRIPT_DIR=`dirname $0`
FCODER_DIR="$1"

WARNING_FLAGS="-Wno-write-strings"
FLAGS="-std=gnu++0x -fno-rtti -fno-exceptions -fPIC -shared -I $FCODER_DIR"

echo "4coder/build.sh: Installing 4coder configuration to $FCODER_DIR/custom_4coder.so"
gcc $WARNING_FLAGS $FLAGS $SCRIPT_DIR/4coder_np3w.cpp -o $FCODER_DIR/custom_4coder.so

