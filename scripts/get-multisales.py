#! /usr/bin/env python

import csv
import sys

n_cols_to_compare = 4
previous_address = [None for i in xrange(n_cols_to_compare)]
n_seen = 1
addresses = []

writer = csv.writer(sys.stdout, delimiter=',', quotechar='"')

for tokens in csv.reader(sys.stdin, delimiter=','):
    values = tokens[:n_cols_to_compare]
    if values != previous_address:
        if n_seen != 1:
            entries_to_write = previous_address
            for address in addresses:
                entries_to_write.extend(address[n_cols_to_compare:])
            writer.writerow(entries_to_write)
        addresses = [tokens]
        n_seen = 1
        previous_address = values
    else:
        n_seen += 1
        addresses.append(tokens)
