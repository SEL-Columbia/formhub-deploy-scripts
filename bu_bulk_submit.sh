echo "Submitting archive to local formhub"
cd /home/formhub/bin/bulk_upload/
PACKAGE_ID=`date | md5sum | cut -c 1-9`
PACKAGE_NAME="package_$PACKAGE_ID"
PACKAGE_ZIP="$PACKAGE_NAME.zip"
sudo mv files $PACKAGE_NAME
sudo zip -r $PACKAGE_ZIP $PACKAGE_NAME

#remove this next line before deploying
sudo mv $PACKAGE_NAME files

curl -F "zip_submission_file=@$PACKAGE_ZIP;type=application/zip" http://localhost/formhub/bulk-submission

