import supervisor 
import storage 

supervisor.set_usb_identification("SISA", "Extractor", 0x239a, 0x80f4)

storage.remount("/", True)