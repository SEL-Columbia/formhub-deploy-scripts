import sys, os, shutil, glob, time, re, datetime
CURRENT_FILE = os.path.abspath(__file__)
CURRENT_DIR = os.path.dirname(CURRENT_FILE)
UNLOAD_DIR = os.path.join(CURRENT_DIR, 'files')

SETTINGS = {
    'UNLOAD_DIR': os.path.join(CURRENT_DIR, 'files'),
    'MOUNT_ROOT': '/Volumes',
    'dont_delete': True,
    'hidden_files_directory': '.odk_backups',
    'clean_odk_dir': os.path.join(CURRENT_DIR, 'odk_fresh')
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
            os.rename(odk_src_dir, backup_dest)
        else:
            # a hack to get around a problem I was having with shutil.rmtree
            hidden_files = glob.glob(os.path.join(odk_src_dir, 'forms', '._*'))
            for f in hidden_files:
                os.remove(f)
            shutil.rmtree(odk_src_dir)

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
        count_instances(drive)
        print "[ctrl-C to quit ]  - A drive is found with %d instances." % count_instances(drive)
        phone_id = raw_input("[ctrl-C to quit ]  - What is the phone's ID number?: ")
        if phone_id.lower() in ["quit", "q"]:
            print "Quitting"
            sys.exit(0)
        ensure_dir(UNLOAD_DIR)
        dest = os.path.join(UNLOAD_DIR, phone_id)
        src_dir = mounted_drives[0]
        load_contents_to_dir(phone_id, dest, src_dir)
        if replace_contents:
            replace_contents_with_skeleton(SETTINGS['clean_odk_dir'], src_dir)
        unmount_drive(os.path.join(src_dir, '..'))
    time.sleep(1)

def main():
    print "Launching script to unload off phones..."
    print "Press control-C to quit"
    print """
    Looking for a fresh ODK directory to put on the phones.
    This allows you to save time loading new forms onto the phone.
    """
    print "...Looking for fresh ODK directory in:"
    print "    '%s'" % SETTINGS['clean_odk_dir']
    replace_contents = False
    if os.path.exists(SETTINGS['clean_odk_dir']):
        print "    --Found it!"
        replace_contents = True
    else:
        print "    --Couldn't find it."
        response = raw_input("Would you like to proceed without replacing the ODK directory? [y/n] ")
        if re.search("y", response):
            print "Okay, cool."
        else:
            print "There was no 'y' in your response. Quitting."
            sys.exit(0)
    while True:
        try:
            poll(replace_contents=replace_contents)
        except KeyboardInterrupt:
            print " ... Quitting"
            sys.exit(0)


if __name__=="__main__":
    main()