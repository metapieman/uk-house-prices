from functools import lru_cache
import logging
import pandas as pd

l = logging.getLogger(__name__)

def get_records_by_first_half_of_postcode(first_half_of_postcode, data):
    return data[data.POSTCODE.str.startswith(f"{first_half_of_postcode} ")]

@lru_cache()
def postcodes_by_ward(ward):
    postcodes = pd.read_csv('postcodes.zip')\
                             .query(f'Ward == "{ward}"').Postcode
    return postcodes

def get_records_by_administrative_area(area, data):
    postcodes = postcodes_by_ward(area)
    l.info(f'found {len(postcodes)} postcodes')
    reduced_data = pd.DataFrame()
    l.info(f'extracting data for postcodes in {area}')
    reduced_data = data[data['POSTCODE'].isin(postcodes)]
    return reduced_data

def get_records(grouping, data):

    if grouping['type'] == 'first half of postcode':
        return get_records_by_first_half_of_postcode(grouping['postcode'], data)

    if grouping['type'] == 'administrative area':
        return get_records_by_administrative_area(grouping['name'], data)

    raise Exception(f"unknown grouping {grouping_name}")
