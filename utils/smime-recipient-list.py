#!/usr/bin/env python3
"""
Given an smime encrypted file and some smime certificates,
tell for which of the smime certificates, the encrypted file has been
encrypted for.
"""

import argparse
import os
import re
import subprocess
import sys
import textwrap


def debug(msg):
    print(f':: {msg}', file=sys.stderr)


class Openssl:
    def __init__(self, openssl_command):
        self.openssl_command = openssl_command

    def get_certificate_serial_number(self, certificate_file):
        """Given a certificate_file filepath, return its serial number as an int"""
        command = [self.openssl_command, 'x509', '-in', certificate_file, '-serial', '-noout']
        # debug(f'running {command}')
        proc = subprocess.run(command, stdout=subprocess.PIPE)
        # output should be of the form 'serial=HEXADECIMALNUMBER'
        try:
            return int(proc.stdout.decode().replace('serial=', ''), 16)
        except ValueError:
             print("Can not read file: {}".format(certificate_file), file=sys.stderr)

    def smime_pk7out(self, encrypted_file):
        """run smime -pk7out, return its output"""
        command = [self.openssl_command, 'smime', '-pk7out']
        command += ['-inform', 'DER', '-in', encrypted_file]
        debug(f'running: {command}')
        proc = subprocess.run(command, stdout=subprocess.PIPE)
        return proc.stdout.decode()

    def pkcs7_serial_numbers(self, pk7buf):
        """extract all serial numbers via openssl pkcs7 -noout -print"""
        command = [self.openssl_command, 'pkcs7', '-noout', '-print']
        proc = subprocess.run(command, stdout=subprocess.PIPE, text=True, input=pk7buf)
        for match in re.finditer(r'serial: (0x[0-9a-fA-F]+|[0-9]+)(\s|$)', proc.stdout):
            yield int(match.group(1), 0)  # base = 0 --> autodetect

    def list_recipient_serial_numbers(self, encrypted_file):
        """Do essentially:
            openssl smime -pk7out -inform DER -in MYMAIL \
                | openssl pkcs7 -noout -print \
                | grep serial
        """
        pk7out = self.smime_pk7out(encrypted_file)
        return list(self.pkcs7_serial_numbers(pk7out))

    def smime_decrypt(self, private_key, certificate, filepath, passin='stdin'):
        """encrypt the given filepath and print to stdout"""
        command = [self.openssl_command, 'smime', '-decrypt', '-passin', passin]
        command += ['-inform', 'DER', '-in', filepath]
        command += ['-inkey', private_key]
        command += ['-recip', certificate]
        subprocess.run(command)

def main():
    """main"""
    description = "Detect recipients of smime encrypted files"
    epilog = textwrap.dedent(r"""
    E.g. you can decrypt an email with the command that picks the
    private key automatically:

        {} \
            --passin stdin --decrypt \
            --private-key ~/.smime/keys/* \
            -- mymail ~/.smime/certificates/*

    If you use mutt, you can set

    set smime_decrypt_command="\
        ~/path/to/smime-recipient-list.py --passin stdin --decrypt \
        --private-key ~/.smime/keys/* \
        -- %f ~/.smime/certificates/KEYPREFIX.*"

    where KEYPREFIX is the prefix of your key (i.e. without the .0 or .1 suffix).
    """.format(sys.argv[0]))
    parser = argparse.ArgumentParser(
        description=description,
        epilog=epilog,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('encryptedfile', help='the encrypted file')
    parser.add_argument('certificates',
                        nargs='+',
                        help='the smime certificate files')
    parser.add_argument('--openssl', default='openssl', help='openssl command name')
    parser.add_argument('--list-serials', action='store_true',
                        help='list serial numbers of certifacts')
    parser.add_argument('--print-path', action='store_true',
                        help='print path of recipient certificates')
    parser.add_argument('--private-keys', nargs='*', default=[], help='private keys for decrypt')
    parser.add_argument('--try-only-private', default=False, action='store_true',
                        help='only read certificate files with a matching private key')
    parser.add_argument('--decrypt', action='store_true',
                        help='decrypt using one of the private keys passed.\
                              the key must have the same file name as the certificate.')
    parser.add_argument('--passin', default='stdin',
                        help='default openssl -passin parameter for decrypt')
    args = parser.parse_args()
    openssl = Openssl(args.openssl)


    private_keys = {}
    for filepath in args.private_keys:
        private_keys[os.path.basename(filepath)] = filepath

    # get the serial number of every smime-certfile:
    serialnum2cert = {}
    for i in args.certificates:
        if not args.try_only_private or os.path.basename(i) in private_keys:
            debug(f'reading serial number of {i}')
            serialnum2cert[openssl.get_certificate_serial_number(i)] = i
    if args.list_serials:
        for serialnum, keyfile in serialnum2cert.items():
            print("{} --> {}".format(keyfile, serialnum))
    recipients = openssl.list_recipient_serial_numbers(args.encryptedfile)
    if args.print_path or args.decrypt:
        matching_keys = []
        for i in recipients:
            #debug(f'mail encrypted for: {i}')
            if i in serialnum2cert:
                matching_keys.append(serialnum2cert[i])
    if args.print_path:
        for i in matching_keys:
            print(i)
    if args.decrypt:
        key_found = None
        for fp in matching_keys:
            if os.path.basename(fp) in private_keys:
                priv_key_path = private_keys[os.path.basename(fp)]
                debug(f'Decryption via key {priv_key_path}')
                # print("We can use {} and {}".format(priv_key_path, fp))
                key_found = (priv_key_path, fp)
        if key_found is None:
            print("No matching private key found.", file=sys.stderr)
            sys.exit(1)
        openssl.smime_decrypt(key_found[0], key_found[1],
                              args.encryptedfile, passin=args.passin)

if __name__ == "__main__":
    main()
