#! /usr/bin/env python

import bisect
import csv
import datetime as dt
import struct
import sys

# # E.g.: 'median/UK_20160101_20160201'
# spec = sys.argv[1]

# region, start, end = spec.split('_')

first_date = dt.datetime.strptime('20050101', '%Y%m%d').date()
last_date  = dt.date.today()
n_all_dates = (last_date - first_date).days
all_dates = [int((first_date + dt.timedelta(i)).strftime('%Y%m%d'))
             for i in xrange(n_all_dates)]

interp_prices = [None for d in all_dates]

def run(input_fname, output_fname, region, start, end):
    start_date = int(start)
    end_date = int(end)

    def in_UK(address):
        return True

    # address_predicate = {
    #     'UK' : in_UK,
    # }[region]

    with open(input_fname, 'rb') as f:
        with open(output_fname, 'w') as f_out:
            while True:
                n_dates_struct = f.read(4)
                if len(n_dates_struct) < 4:
                    break
                n_dates = struct.unpack('i', n_dates_struct)[0]
                data = struct.unpack('=10s' + n_dates*'i' + n_dates*'f', f.read(10 + 8*n_dates))
                postcode = data[0]
                dates = data[1:n_dates + 1]
                prices = data[n_dates + 1:]
                if dates[0] <= start_date and dates[-1] >= end_date:
                    # We'll create a price for each day such that these prices
                    # interpolate between the sold prices.

                    # These will be the indices of the sale dates in the
                    # interpolated_prices list.
                    ind = bisect.bisect_left(all_dates, dates[0])
                    if not (ind != n_all_dates and all_dates[ind] == dates[0]):
                        raise ValueError
                    date_indices = [ind]
                    n_sale_dates_found = 1
                    interp_prices[ind] = prices[0]
                    last_sale_date = dates[-1]
                    start_date_index = None
                    end_date_index = None
                    while all_dates[ind] != last_sale_date and ind < n_all_dates - 1:
                        if all_dates[ind] == start_date:
                            start_date_index = ind
                        ind += 1
                        new_date = all_dates[ind]
                        price = None
                        if new_date in dates:
                            price = prices[dates.index(new_date)]
                            interp_prices[ind] = price
                            date_indices.append(ind)
                            n_sale_dates_found += 1
                        if all_dates[ind] == end_date:
                            end_date_index = ind
                    for price1, price2, index1, index2 in zip(prices[:-1], prices[1:],
                                                          date_indices[:-1], date_indices[1:]):
                        factor = (float(price2)/price1)**(1.0/(index2 - index1))
                        i = index1 + 1
                        while i != index2:
                            interp_prices[i] = interp_prices[i - 1]*factor
                            i += 1
                    assert start_date_index and end_date_index
                    f_out.write('%f,%f\n'%(interp_prices[start_date_index],
                                           interp_prices[end_date_index]))
