import sys, os, shutil, glob, time, re, datetime
from optparse import OptionParser

CURRENT_FILE = os.path.abspath(__file__)
CURRENT_DIR = os.path.dirname(CURRENT_FILE)
UNLOAD_DIR = os.path.join(CURRENT_DIR, 'files')

SETTINGS = {
    'UNLOAD_DIR': os.path.join(CURRENT_DIR, 'files'),
    'MOUNT_ROOT': '/media',
# dont_delete will preserve a hidden directory with
# the files. this is the safe option
    'dont_delete': True,
    'hidden_files_directory': '.odk_backups',
    'clean_odk_dir': os.path.join(CURRENT_DIR, 'odk_fresh'),
    'replace_contents': False,
    'preserve_forms': True,
}

MOUNTED_DRIVE_PATH = os.path.join(SETTINGS['MOUNT_ROOT'], '*', 'odk')

def get_mounted_drives():
    # path to ODK:
    # eg: /Volumes/*/odk in os x
    return glob.glob(MOUNTED_DRIVE_PATH)
    
def count_instances(drive):
    icount = glob.glob(os.path.join(drive, 'instances', '*'))
    return len(icount)

def ensure_dir(dirname):
    if not os.path.exists(dirname):
        os.mkdir(dirname)

def load_contents_to_dir(pn, dest, odk_src_dir):
    if os.path.exists(dest):
        print "Destination already exists. Saving to a modified path."
        load_contents_to_dir(pn, "%s~" % dest, odk_src_dir)
    else:
        # Copying
        shutil.copytree(odk_src_dir, dest)
        print "[ctrl-C to quit ]  - %s: Backed up %d instances to %s" % (str(pn),
            len(glob.glob(os.path.join(dest, 'instances', '*'))),
            dest)
        if SETTINGS['dont_delete']:
            hf_path = os.path.abspath(os.path.join(odk_src_dir, '..', SETTINGS['hidden_files_directory']))
            print "Hidden files dir %s" % hf_path
            if not os.path.exists(hf_path):
                os.mkdir(hf_path)
            timestamp = datetime.datetime.now().strftime("%Y_%m_%d_%H_%M_%S")
            backup_dest = os.path.join(hf_path, 'odk_%s' % timestamp)
            shutil.copytree(odk_src_dir, backup_dest)
        dirs_to_empty = [os.path.join(odk_src_dir, x)
			for x in ['instances', 'metadata']]
        [shutil.rmtree(x) for x in dirs_to_empty]
        [os.mkdir(x) for x in dirs_to_empty]

def replace_contents_with_skeleton(skeleton_dir, odk_src_dir):
    # "skeleton" dir contains the odk directory to be put on the phones after old data is wiped.
    shutil.copytree(skeleton_dir, odk_src_dir)

def unmount_drive(drive_path):
    os.system("sudo umount \"%s\"" % os.path.abspath(drive_path))
    print "[ctrl-C to quit ]  - Drive is ejected."

def poll(replace_contents=False):
    mounted_drives = get_mounted_drives()
    if len(mounted_drives) > 0:
        drive = mounted_drives[0]
        print "[ctrl-C to quit ]  - A phone is found with %d instances." % count_instances(drive)
        phone_id = raw_input("[ctrl-C to quit ]  - What is the phone's ID number?: ")
        if phone_id.lower() in ["quit", "q"]:
            print "Quitting"
            sys.exit(0)
        ensure_dir(UNLOAD_DIR)
        dest = os.path.join(UNLOAD_DIR, phone_id)
        src_dir = mounted_drives[0]
        load_contents_to_dir(phone_id, dest, src_dir)
#        if replace_contents:
#            replace_contents_with_skeleton(SETTINGS['clean_odk_dir'], src_dir)
        unmount_drive(os.path.join(src_dir, '..'))
    time.sleep(1)

def main():
    usage = "Usage: %prog [--flagged-arguments *...]"
    parser = OptionParser(usage)
#    parser.add_option("-s", "--silent", dest="silent",
#                      action="store_true", default=False, help="suppress output")
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
        sys.exit(0)
    if options.debug:
        print "Debug:"
        odict = eval(str(options))
        for key in ["preserve_on_sdcard", "clean_odk_dir", \
		"unmount_drive", "debug", "phone_id", "output_directory", \
		"remove_instances", "drive_path"]:
            print "%s: %s" % (key, odict[key])
        sys.exit(0)

if __name__=="__main__":
    main()
