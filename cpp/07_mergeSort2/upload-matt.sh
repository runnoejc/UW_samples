#!/bin/bash
# Upload ./* on a local box to the appropriate dir on math.whitman.edu
export destFolder="assignments-167"
export destUser="pearsoma"

export destServer="$destUser@math.whitman.edu"
rsync -avP $PWD/* $destServer:$destFolder/
