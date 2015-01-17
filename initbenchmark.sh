#!/bin/bash

source common.sh

if [ ! -d $logdir_base ]; then
  mkdir $logdir_base
fi

if [ ! -d $webdir_base ]; then
  mkdir $webdir_base
fi

# create web page header
  cat <<EOF >> $webdir/index.html
<html>
<head>
<title>Benchmarks</title>
</head>
<body>
<table>
EOF

benchmarks=(`cat benchmarks.list`)
for bm in "${benchmarks[@]}"; do
  echo $bm
  # create publish directory
  if [ ! -d $webdir ]; then
    mkdir $webdir
    chmod -R 755 $webdir
  fi
  # create log directory
  if [ ! -d $logdir ]; then
    mkdir $logdir
  fi
  # append to the web page 
  cat <<EOF >> $webdir/index.html
<tr><td> <a href="$bm/">$bm</a> </td></tr>
EOF

done

  cat <<EOF >> $webdir/index.html
</table>
</body>
</html>
EOF

chmod 755 $webdir/index.html

# create web page footer
