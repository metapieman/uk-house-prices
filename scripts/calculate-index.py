#! /usr/bin/env python

import json
import numpy as np
import pandas as pd
import sys

area_json_file = sys.argv[1]
data_file = sys.argv[2]
stat = sys.argv[3]

with open(area_json_file) as f:
    area_dict = json.load(f)
    postcodes = area_dict['postcodes']

data = pd.read_csv(data_file, names=['postcode', 'price1', 'price2'])

data['change_factor'] = data.price2/data.price1

mask = np.ones(len(data), dtype=bool)
for regex in postcodes:
    matching = data.postcode.str.match(regex, as_indexer=True)
    mask = mask & matching.values


if stat == 'mean':
    output = {'index_factor': data[mask].change_factor.mean()}
elif stat == 'median':
    output = {'index_factor': data[mask].change_factor.median()}
else:
    raise Exception('unknown stat type %s'% stat)

json.dump(output, sys.stdout)
