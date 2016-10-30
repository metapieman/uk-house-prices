#! /usr/bin/env python

import datetime as dt
import sys

# E.g.: 'median/UK_20160101_20160201'
spec = sys.argv[1]

region, start, end = spec.split('_')

start_date = dt.datetime.strptime(start, '%Y%m%d').date()
end_date = dt.datetime.strptime(end, '%Y%m%d').date()

def in_UK(address):
    return True

address_predicate = {
    'UK' : in_UK,
}[region]

for line in sys.stdin:
    values = line.rstrip().split(',')
    address = values[:4]
    price_info = values[4:]
    assert len(price_info) %2 == 0
    if address_predicate(address):
        dates = []
        prices = []
        for i in xrange(len(price_info)/2):
            date_str, price_str = price_info[2*i: 2*(i+1)]
            dates.append(dt.datetime.strptime(date_str, '%Y-%m-%d').date())
            prices.append(int(price_str))
        assert dates == sorted(dates)
        if dates[0] <= start_date and dates[-1] >= end_date:
            # We'll create a price for each day such that these prices
            # interpolate between the sold prices.
            date_indices = [0]
            interpolated_prices = [[dates[0], prices[0]]]
            last_sale_date = dates[-1]
            while interpolated_prices[-1][0] <= last_sale_date:
                new_date = interpolated_prices[-1][0] + dt.timedelta(days=1)
                price = None
                if new_date in dates:
                    price = prices[dates.index(new_date)]
                interpolated_prices.append([new_date, price])
            print interpolated_prices
            print
            print
