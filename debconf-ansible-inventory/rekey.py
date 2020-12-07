#!/usr/bin/env python3
from argparse import ArgumentParser
from itertools import count
from pathlib import Path
import re

from ansible.parsing.vault import VaultLib, VaultSecret, is_encrypted


def rekey_yaml(path, old_vault, new_vault):
    """Rekey an inventory YAML file containing encrypted strings"""
    print(f'Rekeying {path}')

    with path.open() as f:
        lines = f.readlines()

    for i in count():
        try:
            line = lines[i]
        except IndexError:
            break

        if line.endswith(': !vault |\n'):
            start = i + 1
            m = re.search(r'^\s*', line)
            indent = m.group(0) + '  '
            block = []
            for i in count(start):
                try:
                    if lines[i].startswith(indent):
                        block.append(lines[i].lstrip())
                        continue
                    else:
                        break
                except IndexError:
                    break
            end = i
            blockstr = ''.join(block)
            assert is_encrypted(blockstr)

            rekeyed = rekey_block(blockstr, old_vault, new_vault)
            rekeyed = [indent + line + '\n' for line in rekeyed.split('\n')]
            lines[start:end] = rekeyed

        i += 1

    with path.open('w') as f:
        f.writelines(lines)


def rekey_block(body, old_vault, new_vault):
    plaintext = old_vault.decrypt(body)
    rekeyed = new_vault.encrypt(plaintext).decode('ascii').rstrip()
    return rekeyed


def load_secret(path, vault_id='default'):
    """ansible vault's get_file_vault_secret() is too annoying to use
    (it needs a loader etc.)
    """
    with open(path, 'rb') as f:
        secret = VaultSecret(_bytes=f.read().strip(b'\r\n'))

    return ('default', secret)


def main():
    p = ArgumentParser()
    p.add_argument('--old-vault-password-file')
    p.add_argument('--new-vault-password-file')
    args = p.parse_args()

    old_secret = load_secret(args.old_vault_password_file)
    new_secret = load_secret(args.new_vault_password_file)
    old_vault = VaultLib(secrets=[old_secret])
    new_vault = VaultLib(secrets=[new_secret])

    for path in Path('inventory').glob('*_vars/*'):
        if path.is_file():
            rekey_yaml(path, old_vault, new_vault)


if __name__ == '__main__':
    main()
