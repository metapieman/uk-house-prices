#! /usr/bin/env python3

import datetime
import numpy
import pandas
import sys

def decorate_data(fname, headerfile):
    """Get a pandas DataFrame from a land registry file, with a few extra
    useful columns.
    """
    df = pandas.read_csv(fname, header=None, index_col=False)
    with open(headerfile) as f:
        header = f.readline().rstrip()
        columns = header.split(',')
        df.columns = columns
    df['Date'] = pandas.to_datetime(df['Date'])
    # create a 'Month' column that contains the first day of the month
    # in the 'Date' column
    def strip_day_info(date):
        first_day_of_month = datetime.date(year=date.year,
                                           month=date.month,
                                           day=1)
        return first_day_of_month.strftime('%Y-%m-%d')
    df['Month']  = pandas.to_datetime(df['Date'].apply(strip_day_info))
    df['IsFlat'] = df['PropertyType']=='F'
    df['AreaPostcode'] = df['Postcode'].str.split(' ').str.get(0)
    df['FullAddress'] = (df.SAON + ' ' + df.PAON + ' ' +
                         df.Street + ' ' + df.AreaPostcode)
    df['NewBuild'] = df['PropertyAge']=='Y'
    return df

def summarize_data(df, remove_category_b=True):
    """df is the output of decorate_data. Produces a summary dataframe
    with mean/median/count/stderr of price.

    *** Explanation of 'Category B' ***

    Explanation of Category Type field From Land Registry website
    (https://www.gov.uk/guidance/about-the-price-paid-data):

    A = Standard Price Paid entry, includes single residential
    property sold for full market value.

    B = Additional Price Paid entry including transfers under a power
    of sale/repossessions, buy-to-lets (where they can be identified
    by a Mortgage) and transfers to non-private individuals.

    Type B was recently added to the data-set. Exclude it by default
    because it seems potentially less trustworthy.
    """
    reduced_df = df[['Price','Month','LocalAuthority','IsFlat','NewBuild']]
    if remove_category_b:
        if 'CategoryType' in df.columns:
            reduced_df = reduced_df[df.CategoryType != 'B']
    grouped = reduced_df.groupby(['LocalAuthority','Month','IsFlat','NewBuild'])
    def stderr(x): return numpy.std(x)/numpy.sqrt(len(x))
    data = grouped.agg([numpy.mean,numpy.median,len,stderr]).unstack(
        'LocalAuthority').swaplevel(0,1,axis=1)
    data.columns = data.columns.droplevel(1) # get rid of the 'Price'
                                             # index which is
                                             # redundant
    data = data.unstack(['IsFlat','NewBuild']) # make IsFlat, NewBuild column indices
    colnames = [c for c in data.columns.names]
    colnames[0] = 'Statistic'
    data.columns.names = colnames
    melted = pandas.melt(data.reset_index(), id_vars=['Month'])
    melted['Type'] = 'House'
    melted.loc[melted['IsFlat'], 'Type'] = 'Flat'
    del melted['IsFlat']
    melted['Age'] = 'Period'
    melted.loc[melted['NewBuild'], 'Type'] = 'New-build'
    del melted['NewBuild']
    cols = []
    for c in melted.columns:
        if c == 'value':
            cols.append('Price')
        else:
            cols.append(c)
    melted.columns = cols
    return melted

if __name__=='__main__':
    datafile = sys.argv[1]
    headerfile = sys.argv[2]
    df = decorate_data(datafile, headerfile)
    summary = summarize_data(df)
    summary.to_csv(sys.stdout, index=False)
