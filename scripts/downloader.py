import serial
import time
from xmodem import XMODEM

# Configuration
PORT = 'COM10'  # À adapter (/dev/ttyUSB0 sur Linux)
BAUD = 115200
#FILENAME = 'picoRV32_HDMI.bin'
FILENAME = 'D:\eclipse\workspace.risc\picoRV32_HDMI\Debug_App\picoRV32_HDMI.bin'

def getc(size, timeout=1):
    global ser
    return ser.read(size) or None

def putc(data, timeout=1):
    global ser
    return ser.write(data)

def progress_callback(total_packets, success_count, error_count):
    print(f"Transfert en cours... Blocs envoyes: {success_count}") #, end='\r')



def send_file(port, filename):
    global ser
    try:
        ser = serial.Serial(port, BAUD, timeout=5)
        print(f"Ouverture du port {port}...")
        
        # On attend un peu que le FPGA reboot ou envoie son 'C'
        print("En attente du signal du FPGA ('CRC_READY/NAK')...")
        
        xm = XMODEM(getc, putc, mode='xmodem', pad=b'\x00')
        with open(filename, 'rb') as f:
            status = xm.send(f, callback=progress_callback, retry=3)
        
        if status:
            print("\n[OK] Transfert réussi !")
        else:
            print("\n[ERREUR] Echec du transfert.")

        ser.close()
    except Exception as e:
        print(f"\nErreur : {e}")




if __name__ == "__main__":   
    print("downloader")
    send_file(PORT, FILENAME)