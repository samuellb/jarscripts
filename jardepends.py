#!/usr/bin/env python3

# jardepends -- displays other .jar files which a jar references
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



import zipfile, email.parser, os.path, sys


def get_manifest(jar_path):
    #with zipfile.ZipFile(jar_path, 'r') as zf:
    zf = zipfile.ZipFile(jar_path, 'r')
    contents = zf.read('META-INF/MANIFEST.MF')
    zf.close()
    return contents.decode('utf-8')


def get_classpath_from_manifest(manifest):
    parser = email.parser.FeedParser()
    parser.feed(manifest)
    msg = parser.close()
    
    cp = msg.get('Class-Path', None)
    if cp is None: return []
    else: return cp.replace('\r\n ', '').replace('\r\n', '').split(' ')


def get_jar_depends(jar_path):
    return get_classpath_from_manifest(get_manifest(jar_path))


def get_jar_depends_deep(jar_path):
    deps = [jar_path]
    newdeps = [jar_path]
    
    while len(newdeps) != 0:
        jar = newdeps.pop()
        jardir = os.path.dirname(jar)
        
        try:
            jardeps = get_jar_depends(jar)
        except IOError:
            sys.stderr.write('Failed to open: '+str(jar)+'\n')
            continue
        
        yield jar
        
        for dep in jardeps:
            dep = os.path.normpath(jardir + "/" + dep)
            if not dep in deps:
                deps.append(dep)
                newdeps.append(dep)


if __name__ == '__main__':
    jarfile = sys.argv[1]
    for dep in get_jar_depends_deep(jarfile):
        print(dep)

    

