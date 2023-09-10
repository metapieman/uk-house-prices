from functools import lru_cache
import logging
import pandas as pd

logger = logging.getLogger(__name__)


def get_records_by_first_half_of_postcode(first_half_of_postcode, data):
    return data[data.POSTCODE.str.startswith(f"{first_half_of_postcode} ")]


def get_records_by_local_authority(local_authority, data):
    return data[data.LOCALAUTHORITY == local_authority.upper()]


@lru_cache()
def postcode_data():
    postcodes = pd.read_csv(
        'pcd11_par11_wd11_lad11_ew_lu.csv.gz',
        low_memory=False)
    return postcodes


@lru_cache()
def postcodes_by_ward(ward):
    postcodes = postcode_data()
    postcodes = postcodes.query(f'wd11nm == "{ward}"').pcd7
    return postcodes


def get_records_by_administrative_area(area, data):
    postcodes = postcodes_by_ward(area)
    logger.info(f'found {len(postcodes)} postcodes for {area}')
    reduced_data = pd.DataFrame()
    logger.info(f'extracting data for postcodes in {area}')
    reduced_data = data[data['POSTCODE'].str.replace(' ', '').isin(
        postcodes.str.replace(' ', ''))]
    return reduced_data


def get_records(grouping, data):

    if grouping['type'] == 'first half of postcode':
        return get_records_by_first_half_of_postcode(
            grouping['postcode'], data)

    if grouping['type'] == 'administrative area':
        return get_records_by_administrative_area(grouping['name'], data)

    if grouping['type'] == 'local authority':
        return get_records_by_local_authority(grouping['name'], data)

    raise Exception(f"unknown grouping {grouping}")
