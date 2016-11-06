#! /usr/bin/env python

import csv
import struct
import sys

n_cols_to_compare = 4
previous_address = [None for i in xrange(n_cols_to_compare)]
n_seen = 1
full_lines = []

output_fname = sys.argv[1]

with open(output_fname,'wb') as f_out:
    for tokens in csv.reader(sys.stdin, delimiter=','):
        address = tokens[:n_cols_to_compare]
        if address != previous_address:
            if n_seen != 1:
                postcode = previous_address[3]
                date_str, price_str = full_lines[0][n_cols_to_compare:]
                dates = [int(date_str.replace('-', ''))]
                prices = [float(price_str)]
                for full_line in full_lines[1:]:
                    date_str, price_str = full_line[n_cols_to_compare:]
                    date = int(date_str.replace('-', ''))
                    price = float(price_str)
                    # If >1 price on a single day, overwrite (i.e., take
                    # the last one only)
                    if date == dates[-1]:
                        prices[-1] = price
                    else:
                        dates.append(date)
                        prices.append(price)
                # Check that there were sales on > 1 date (repeated sales
                # on a single date do not count)
                n_dates = len(dates)
                if n_dates > 1:
                    assert len(postcode) <= 10
                    postcode = postcode.ljust(10, ' ')
                    args = [n_dates, postcode] + dates + prices
                    binary = struct.pack('=i10s' + 'i'*n_dates + 'f'*n_dates, *args)
                    f_out.write(binary)
                    #writer.writerow(entries_to_write)
            full_lines = [tokens]
            n_seen = 1
            previous_address = address
        else:
            n_seen += 1
            full_lines.append(tokens)
