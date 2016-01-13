#!/bin/bash
# Upload ./* on a local box to the appropriate dir on math.whitman.edu
export destFolder="167/SubVersion"
export destUser="runnoejc"

export destServer="$destUser@math.whitman.edu"
rsync -avP $PWD/* $destServer:$destFolder/
