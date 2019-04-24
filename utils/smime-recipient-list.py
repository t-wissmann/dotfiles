#!/usr/bin/env python3
"""
Given an smime encrypted file and some smime certificates,
tell for which of the smime certificates, the encrypted file has been
encrypted for.
"""

import argparse
import subprocess
import re

class Openssl:
    def __init__(self, openssl_command):
        self.openssl_command = openssl_command

    def get_certificate_serial_number(self, certificate_file):
        """Given a certificate_file filepath, return its serial number as an int"""
        command = [self.openssl_command, 'x509', '-in', certificate_file, '-serial', '-noout']
        proc = subprocess.run(command, stdout=subprocess.PIPE)
        # output should be of the form 'serial=HEXADECIMALNUMBER'
        return int(proc.stdout.decode().replace('serial=', ''), 16)

    def smime_pk7out(self, encrypted_file):
        """run smime -pk7out, return its output"""
        command = [self.openssl_command, 'smime', '-pk7out']
        command += ['-inform', 'DER', '-in', encrypted_file]
        proc = subprocess.run(command, stdout=subprocess.PIPE)
        return proc.stdout.decode()

    def pkcs7_serial_numbers(self, pk7buf):
        """extract all serial numbers via openssl pkcs7 -noout -print"""
        command = [self.openssl_command, 'pkcs7', '-noout', '-print']
        proc = subprocess.run(command, stdout=subprocess.PIPE, text=True, input=pk7buf)
        for match in re.finditer('serial: ([0-9]+)', proc.stdout):
            yield int(match.group(1))


    def list_recipient_serial_numbers(self, encrypted_file):
        """Do essentially:
            openssl smime -pk7out -inform DER -in MYMAIL \
                | openssl pkcs7 -noout -print \
                | grep serial
        """
        pk7out = self.smime_pk7out(encrypted_file)
        return list(self.pkcs7_serial_numbers(pk7out))

def main():
    """main"""
    description = "Detect recipients of smime encrypt"
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument('encryptedfile', help='the encrypted file')
    parser.add_argument('certificates',
                        nargs='+',
                        help='the smime certificate files')
    parser.add_argument('--openssl', default='openssl', help='openssl command name')
    args = parser.parse_args()
    openssl = Openssl(args.openssl)

    # get the serial number of every smime-certfile:
    serialnum2cert = {}
    for i in args.certificates:
        serialnum2cert[openssl.get_certificate_serial_number(i)] = i
    for serialnum, keyfile in serialnum2cert.items():
        print("{} --> {}".format(keyfile, serialnum))
    recipients = openssl.list_recipient_serial_numbers(args.encryptedfile)
    print(recipients)
    for i in recipients:
        if i in serialnum2cert:
            print(serialnum2cert[i])

    # get the serial numbers in the file via:

if __name__ == "__main__":
    main()
