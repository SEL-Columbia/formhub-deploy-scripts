import sys, os, shutil, glob, time, re, datetime
from optparse import OptionParser

def load_contents_to_dir(phone_id, dest, odk_src_dir):
    if os.path.exists(dest):
        print "Destination already exists. Saving to a modified path.\n"
        load_contents_to_dir(phone_id, "%s~" % dest, odk_src_dir)
    else:
        shutil.copytree(odk_src_dir, dest)

def backup_on_sdcard(odk_src_dir):
    hf_path = os.path.abspath(os.path.join(odk_src_dir, '..', '.odk_backups'))
    if not os.path.exists(hf_path):
        os.mkdir(hf_path)
    timestamp = datetime.datetime.now().strftime("%Y_%m_%d_%H_%M_%S")
    backup_dest = os.path.join(hf_path, 'odk_%s' % timestamp)
    shutil.copytree(odk_src_dir, backup_dest)

def remove_instances_and_metadata(odk_src_dir):
    dirs_to_empty = [os.path.join(odk_src_dir, x)
        for x in ['instances', 'metadata']]
    for x in dirs_to_empty: shutil.rmtree(x)
    for x in dirs_to_empty: os.mkdir(x)

def run(options):
    """
    preserve_on_sdcard: False
    clean_odk_dir: None
    debug: True
    phone_id: 1256
    output_directory: /home/formhub/Desktop/Unloaded Data
    remove_instances: True
    drive_path: /media/Kingston
    """
    odk_src_dir = os.path.join(options.drive_path, 'odk')
    try:
        load_contents_to_dir(options.phone_id, os.path.join(options.output_directory, options.phone_id), odk_src_dir)
    except:
        print "There was a problem copying ODK contents"
        sys.exit(2)
    if options.preserve_on_sdcard:
        try:
            backup_on_sdcard(odk_src_dir)
        except:
            print "There was a problem backing up data on SD card"
            sys.exit(2)
    if options.remove_instances:
        remove_instances_and_metadata(odk_src_dir)

def main():
    usage = "Usage: %prog [--flagged-arguments *...]"
    parser = OptionParser(usage)
    parser.add_option("-B", "--preserve-on-sdcard", dest="preserve_on_sdcard",
                      action="store_true", default=False, help="data can be moved to "
                      "a hidden directory on  the sdcard. This is a measure to prevent data "
                      "loss but should be avoided with sensitive data.")
    parser.add_option("-o", "--output-directory", dest="output_directory",
                      action="store", help="destination to unload the contents.")
    parser.add_option("-r", "--remove-instances", dest="remove_instances",
                      action="store_true", default=False,
                      help="Cleans out the odk/instances and odk/metadata directories after "
                           "unload is complete")
    parser.add_option("-u", "--unmount-drive", dest="unmount_drive",
                      action="store_true", default=False, help="unmounts the drive after copying"
                      " is complete.")
    parser.add_option("--phone-id", dest="phone_id",
                      action="store", help="A phone ID that is used to name the directory")
    parser.add_option("--drive-path", dest="drive_path",
                      action="store", help="The path to the drive that will be unloaded.")
    parser.add_option("-C", "--clean-odk-dir", dest="clean_odk_dir",
                      action="store", help="path to a prepared ODK directory."
                      "(helpful for auto-loading forms onto phones.)")
    parser.add_option("-D", "--debug", dest="debug",
                      action="store_true", default=False, help="Prints debug information and then "
                      "exits.")
    (options, args) = parser.parse_args()
    if len(args) > 0:
        print "This script takes no unflagged arguments"
        sys.exit(2)
    if options.debug:
        print "Debug:"
        odict = eval(str(options))
        for key in ["preserve_on_sdcard", "clean_odk_dir", \
		"unmount_drive", "debug", "phone_id", "output_directory", \
		"remove_instances", "drive_path"]:
            print "%s: %s" % (key, odict[key])
        sys.exit(2)
    run(options)

if __name__=="__main__":
    main()
