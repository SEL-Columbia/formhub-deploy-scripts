echo "Submitting archive to local formhub"
#cd /home/formhub/bin/bulk_upload/
#PACKAGE_ID=`date | md5sum | cut -c 1-9`
#PACKAGE_NAME="package_$PACKAGE_ID"
#PACKAGE_ZIP="$PACKAGE_NAME.zip"
#sudo mv files $PACKAGE_NAME
#sudo zip -r $PACKAGE_ZIP $PACKAGE_NAME

FH_DESKTOP="/home/formhub/Desktop"
ORIGIN_FILES="$FH_DESKTOP/UnloadedData"
BACKUP_DEST="$FH_DESKTOP/PriorUploads"
TIMESTAMP=`date +%m_%d_%H_%M_%S`

PACKAGE_ZIP="$BACKUP_DEST/Submitted_$TIMESTAMP.zip"

mkdir -p "$BACKUP_DEST"

zip -r $PACKAGE_ZIP $ORIGIN_FILES

if [ $? = 0 ]; then
  RESULT=$(curl -F "zip_submission_file=@$PACKAGE_ZIP;type=application/zip" http://localhost/formhub/bulk-submission)
  if [ $? = 0 ]; then
    echo "Success! $RESULT"
    rm -rf 
  else
    echo "There was a problem with your submission."
  fi
fi

