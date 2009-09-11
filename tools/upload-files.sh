#!/bin/sh

. upload.conf

cp ../QUICK* ../RELEASE_NOTES ../UPGRADING ../conf/CONFIGURING \
    ../READMEs/*.README .
upload_files="QUICK* RELEASE_NOTES UPGRADING CONFIGURING *.README"

#cp ../RELEASE_NOTES ../UPGRADING ../conf/CONFIGURING ../READMEs/*.README .
#upload_files="RELEASE_NOTES UPGRADING CONFIGURING *.README"

release_file=RELEASE_NOTES
dt=`date +%d%b%G`

ftp -n -v $uploadhost <<EOF
user $uploaduser
prompt
mkdir $uploaddir
cd $uploaddir
mkdir Docs
cd Docs
mdelete *
mput $upload_files
rename $release_file $release_file-$dt
quit
EOF

rm $upload_files $readme_files
