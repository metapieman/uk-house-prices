
def get_records_by_first_half_of_postcode(first_half_of_postcode, data):
    return data[data.POSTCODE.str.startswith(f"{first_half_of_postcode} ")]

first_half_of_postcode_areas = {
    "hampstead": "NW3",
    "highgate": "N6"
}

def get_records(grouping_name, data):

    if grouping_name in first_half_of_postcode_areas:
        return get_records_by_first_half_of_postcode(first_half_of_postcode_areas[grouping_name], data)

    raise Exception(f"unknown grouping {grouping_name}")
