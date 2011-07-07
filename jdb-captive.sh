#!/bin/sh

# JDB Captive -- Version 0.1
#
# Copyright (c) 2011 Samuel Lidén Borell
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.



# How to use:
#   1. Start this script. It starts a shell
#   2. Start any processes that spawn Java processes from the new shell
#   3. Find out the port of the java processes with either of the following:
#       (a) the "captive-log", from INSIDE the captive shell
#       (b) with "less /tmp/tmp.*-captive/.log"
#       (c) with "netstat -tuan"
#   4. jdb -attach PORT


EXEC_OVERRIDES="`mktemp -d --suffix=-captive`"
ORIG_JAVA="`which java`"


# Set up a counter for the debug ports so more than one java can run
PORTCOUNTER="$EXEC_OVERRIDES/.portcounter"
mkdir "$PORTCOUNTER"
touch "$PORTCOUNTER/12000"


# Create a wrapper for java
ASTERISK='*'
cat > "$EXEC_OVERRIDES/java" <<EOF
#!/bin/sh

nextport() {
    while true; do
        counter=\`echo "$PORTCOUNTER"/$ASTERISK | grep -oE '[0-9]+$'\`
        next=\$((counter+1))
        #echo mv "$PORTCOUNTER/\$counter" "$PORTCOUNTER/\$next" >&2
        mv "$PORTCOUNTER/\$counter" "$PORTCOUNTER/\$next" && { echo "\$next"; break; }
    done
}

PORT="\`nextport\`"
#printf "\n\n\n\n\n\n\nPORT ----> %s\n\n\n\n\n\n" "\$PORT"

echo "\$PORT    java \$@" >> "$EXEC_OVERRIDES/.log"

exec $ORIG_JAVA -Xdebug -Xrunjdwp:transport=dt_socket,address="\$PORT",server=y,suspend=n "\$@"

EOF


# Create command to show the log
cat > "$EXEC_OVERRIDES/captive-log" <<EOF
less "$EXEC_OVERRIDES/.log"
EOF


chmod +x "$EXEC_OVERRIDES/java" "$EXEC_OVERRIDES/captive-log"

# Add it to path
export PATH="$EXEC_OVERRIDES:$PATH"


# Start shell
# TODO start the user's preferred shell

echo "JDB Captive is active in this shell. Type \"exit\" to leave."
bash


# Cleanup
echo "Exited JDB Captive"
rm "$EXEC_OVERRIDES/java" "$EXEC_OVERRIDES/captive-log"
rm -rf "$PORTCOUNTER"
rmdir "$EXEC_OVERRIDES"


