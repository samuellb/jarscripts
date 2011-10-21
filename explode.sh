#!/bin/sh

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


if [ -z "$1" ]; then
    echo "usage: explode jar-files..." >&2
    echo >&2
    echo "It supports all of the Java archive formats, including .ear," >&2
    echo ".war, etc. as long as they end in .?ar and are ZIP files." >&2
    exit 2
fi

explode_dir() {
    #echo "exploding $1..."
    mkdir -- "$1.d"
    unzip -q -d "$1.d" -- "$1" 
    
    find "$1.d" -iname '*.?ar' | while read jar; do
        explode_dir "$jar"
    done
}

while [ $# != 0 ]; do
    explode_dir "$1"
    #echo "dir:$1"
    
    shift
done

