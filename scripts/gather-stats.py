#! /usr/bin/env python3

import json
import os
import pandas as pd
import sys
from typing import List

index_factors = []
dates: List[int] = []

for fname in sys.argv[1:]:
    start_date_str, end_date_str, _ = os.path.basename(fname).replace(
        '_', '.').split('.')
    if dates == []:
        index_factors.append(1.0)
        dates.append(int(start_date_str))
    dates.append(int(end_date_str))
    with open(fname) as f:
        d = json.load(f)
        index_factors.append(d['index_factor'])

df = pd.DataFrame({
    'date': dates,
    'index': index_factors,
}).set_index('date')

df.cumprod().reset_index().to_csv(sys.stdout, index=False)
