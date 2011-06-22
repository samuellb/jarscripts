#!/bin/bash

# first version written by Johan Eklund.
# updated by Samuel Lidén Borell


NAME="$1"

UNZGREP="`tempfile -p unzipandgrep`"
trap 'rm "$UNZGREP"' 0

ESC="`printf '\033'`"
COLOR="$ESC[34m"
NORMAL="$ESC[0m"

cat >> "$UNZGREP" <<EOF
TEMP="\`unzip -l \$1 | grep $NAME\`"
if [ "x\$TEMP" != "x" ]; then
    echo "$COLOR\$1$NORMAL"
    echo "\$TEMP"
fi
EOF

echo "Searching for $NAME..."

#find . -name "*.jar" -exec bash -c 'echo "$1 `unzip -l $1 | grep $NAME`"' {} {} \;
find . -name "*.jar" -exec sh -c ". $UNZGREP \"\$1\"" {} {} \; 2>/dev/null


