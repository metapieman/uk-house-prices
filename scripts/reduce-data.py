#! /usr/bin/env python3

import pandas as pd
import sys

data_fname, header_fname  = sys.argv[1:]
with open(header_fname) as f:
    cols = f.readline().rstrip().split(',')
df = pd.read_csv(data_fname, names=cols)
cols = ['PAON', 'SAON', 'Street', 'Postcode', 'Date', 'Price']
df[cols].to_csv(sys.stdout, index=False, header=None)

