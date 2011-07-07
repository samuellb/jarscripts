#!/bin/bash

# based on findinjar.sh
# written by Samuel Lidén Borell


if [ $# = 1 ]; then
    PATTERN="*.xml"
    REGEX="$1"
elif [ $# = 2 ]; then
    PATTERN="$1"
    REGEX="$2"
else
    cat >&2 <<EOF
usage: finddeepinjar [file pattern] regex

Where file pattern is anything that "unzip" accepts, and regex is a regular
expression to search for. The default file pattern is *.xml
EOF
    exit
fi

UNZGREP="`tempfile -p unzipandgrep`"
trap 'rm "$UNZGREP"' 0

ESC="`printf '\033'`"
COLOR="$ESC[34m"
NORMAL="$ESC[0m"

cat >> "$UNZGREP" <<EOF
TEMP="\`unzip -p \$1 '$PATTERN' | grep -E --color=yes "$REGEX"\`"
if [ "x\$TEMP" != "x" ]; then
    echo "$COLOR\$1$NORMAL"
    echo "\$TEMP"
fi
EOF

echo "Searching deep for $REGEX in $PATTERN..."

find . -name "*.jar" -exec sh -c ". $UNZGREP \"\$1\"" {} {} \; 2>/dev/null


