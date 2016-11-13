#! /usr/bin/env python

import sys

# E.g.: NorthLondon/mean/20160101_20160201
try:
    spec = sys.argv[1]
    area, stat, dates = spec.split('/')
    print 'areas/%s.json data/index_data/%s.csv'% (area, dates)
except:
    sys.stderr.write('get-index-dependencies.py: something went wrong, sys.argv: %s\n'% str(sys.argv))
    print 'ERROR'
