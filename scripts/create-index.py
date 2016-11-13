#! /usr/bin/env python

import csv
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

for values in csv.reader(sys.stdin, delimiter=','):
    address = values[:4]
    price_info = values[4:]
    assert len(price_info) %2 == 0, '%s'% str(values)
    if address_predicate(address):
        date_str, price_str = price_info[0:2]
        dates = []; prices = []
        dates.append(dt.datetime.strptime(date_str, '%Y%m%d').date())
        prices.append(float(price_str))
        for i in xrange(1, len(price_info)/2):
            date_str, price_str = price_info[2*i: 2*(i+1)]
            date = dt.datetime.strptime(date_str, '%Y%m%d').date()
            price = float(price_str)
            if date == dates[-1]:
                prices[-1] = price
            else:
                dates.append(dt.datetime.strptime(date_str, '%Y%m%d').date())
                prices.append(int(price_str))
        assert dates == sorted(dates)
        if dates[0] <= start_date and dates[-1] >= end_date:
            # We'll create a price for each day such that these prices
            # interpolate between the sold prices.

            # These will be the indices of the sale dates in the
            # interpolated_prices list.
            date_indices = [0]
            interpolated_prices = [[dates[0], prices[0]]]
            last_sale_date = dates[-1]
            start_date_index = None
            end_date_index = None
            while interpolated_prices[-1][0] != last_sale_date:
                if interpolated_prices[-1][0] == start_date:
                    start_date_index = len(interpolated_prices) - 1
                new_date = interpolated_prices[-1][0] + dt.timedelta(days=1)
                price = None
                if new_date in dates:
                    price = prices[dates.index(new_date)]
                interpolated_prices.append([new_date, price])
                if new_date == dates[len(date_indices)]:
                    date_indices.append(len(interpolated_prices) - 1)
                if interpolated_prices[-1][0] == end_date:
                    end_date_index = len(interpolated_prices) - 1
            for price1, price2, index1, index2 in zip(prices[:-1], prices[1:],
                                                  date_indices[:-1], date_indices[1:]):
                factor = (float(price2)/price1)**(1.0/(index2 - index1))
                i = index1 + 1
                while i != index2:
                    interpolated_prices[i][1] = interpolated_prices[i - 1][1]*factor
                    i += 1
            assert start_date_index and end_date_index
            print '%i,%i'%(interpolated_prices[start_date_index][1],
                           interpolated_prices[end_date_index][1])

