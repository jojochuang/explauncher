#!/bin/bash

source common.sh

if [ ! -d $logdir_base ]; then
  mkdir $logdir_base
fi

if [ ! -d $scratchdir ]; then
  mkdir $scratchdir
fi

if [ ! -d $webdir_base ]; then
  mkdir $webdir_base
fi

# create web page header
  cat <<EOF > $webdir_base/index.html
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
  if [ ! -d $webdir_base/$bm ]; then
    mkdir $webdir_base/$bm
    chmod -R 755 $webdir_base/$bm
  fi
  # create log directory
  if [ ! -d $logdir_base/$bm ]; then
    mkdir $logdir_base/$bm
  fi
  # append to the web page 
  cat <<EOF >> $webdir_base/index.html
<tr><td> <a href="$bm/">$bm</a> </td></tr>
EOF

done

  cat <<EOF >> $webdir_base/index.html
</table>
</body>
</html>
EOF

chmod 755 $webdir_base/index.html

# create web page footer
