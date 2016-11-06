#! /usr/bin/env python

import csv
import sys

n_cols_to_compare = 4
previous_address = [None for i in xrange(n_cols_to_compare)]
n_seen = 1
full_lines = []

writer = csv.writer(sys.stdout, delimiter=',', quotechar='"')

for tokens in csv.reader(sys.stdin, delimiter=','):
    address = tokens[:n_cols_to_compare]
    if address != previous_address:
        if n_seen != 1:
            entries_to_write = previous_address
            entries_to_write.extend(full_lines[0][n_cols_to_compare:])
            for full_line in full_lines[1:]:
                date, price = full_line[n_cols_to_compare:]
                # If >1 price on a single day, overwrite (i.e., take
                # the last one only)
                if date == entries_to_write[-2]:
                    entries_to_write[-1] = price
                else:
                    entries_to_write.extend([date, price])
            # Check that there were sales on > 1 date (repeated sales
            # on a single date do not count)
            if (len(entries_to_write) - n_cols_to_compare)/2 > 1:
                writer.writerow(entries_to_write)
        full_lines = [tokens]
        n_seen = 1
        previous_address = address
    else:
        n_seen += 1
        full_lines.append(tokens)
