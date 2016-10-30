#! /usr/bin/env python

import sys

n_cols_to_compare = 4
previous_address = [None for i in xrange(n_cols_to_compare)]
n_seen = 1
addresses = []

for line in sys.stdin:
    values = line.split(',')[:n_cols_to_compare]
    if values != previous_address:
        if n_seen != 1:
            sys.stdout.write(' '.join(previous_address) + ',')
            price_data = []
            for line in addresses:
                values = line.rstrip().split(',')
                price_data.extend(values[n_cols_to_compare:])
            sys.stdout.write(','.join(price_data) + '\n')
        addresses = [line]
        n_seen = 1
        previous_address = values
    else:
        n_seen += 1
        addresses.append(line)
