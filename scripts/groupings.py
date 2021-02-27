
def get_records_by_first_half_of_postcode(first_half_of_postcode, data):
    return data[data.POSTCODE.str.startswith(f"{first_half_of_postcode} ")]

def get_records(grouping, data):

    if grouping['type'] == 'first half of postcode':
        return get_records_by_first_half_of_postcode(grouping['postcode'], data)

    raise Exception(f"unknown grouping {grouping_name}")
