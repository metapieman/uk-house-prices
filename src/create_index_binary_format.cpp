#include <algorithm>
#include <cstdint>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

#include <stdio.h>
#include <stdlib.h>

std::vector<int> get_all_dates(std::string dates_file) {
  std::vector<int> dates;
  int date;
  std::ifstream infile(dates_file);
  while (infile >> date) {
    dates.push_back(date);
  }
  return dates;
}

// Returns the number of dates/prices in the next entry, or 0 if we're
// at the end, or negative on error.
int read_record(FILE* handle, char* postcode,
                int32_t* dates, float* prices,
                int max_num_sales) {
  static int32_t n_sales;
  int n_read = fread((void*) &n_sales, 4, 1, handle);
  if (feof(handle)) {
    if (n_read != 0) {
      std::cerr
        << "read_record(): unexpected end of file with " << n_read
        << " bytes read" << std::endl;
      return -6;
    }
    return 0;
  }
  if (n_read != 1) {
    std::cerr
      << "read_record(): failed to read initial 4 bytes of "
      "record, instead got " << n_read << std::endl;
    return -1;
  }
  if (n_sales > max_num_sales) {
    std::cerr
      << "read_record(): n_sales " << n_sales << " exceeds max_num_sales "
      << max_num_sales << std::endl;
    return -2;
  }
  if (fread((void*) postcode, 8, 1, handle) != 1) {
    std::cerr
      << "read_record(): failed to read 8 byte postcode string" << std::endl;
    return -3;
  }
  if (fread((void*) dates, 4, n_sales, handle) != n_sales) {
    std::cerr
      << "read_record(): failed to read " << n_sales << " dates" << std::endl;
    return -4;
  }
  if (fread((void*) prices, 4, n_sales, handle) != n_sales) {
    std::cerr
      << "read_record(): failed to read " << n_sales << " prices" << std::endl;
    return -5;
  }
  return n_sales;
}

int main(int argc, char* argv[]) {
  std::string dates_file(argv[1]);
  std::string binary_data_file(argv[2]);
  std::vector<int> all_dates = get_all_dates(dates_file);
  if (all_dates.empty()) {
    // error
    return 3;
  }
  std::vector<float> interp_prices(all_dates.size(), 0.0);
  int start_date = atoi(argv[3]);
  int end_date = atoi(argv[4]);
  FILE* handle = fopen (binary_data_file.c_str(), "rb");
  std::vector<int> date_indices;
  if (handle != NULL)
  {
    char postcode[12];
    postcode[8] = '\0';
    int32_t dates[24];
    float prices[24];
    while (true) {
      int n_sales = read_record(handle, postcode, dates, prices, 24);
      if (n_sales < 0) {
        // error
        return 1;
      }
      if (n_sales == 0) {
        break;
      }
      if (dates[0] <= start_date && dates[n_sales - 1] >= end_date) {
        std::vector<int>::iterator it;
        it = std::find(all_dates.begin(), all_dates.end(), dates[0]);
        if (it == all_dates.end()) {
          // not found, error
          return 4;
        }
        int ind = std::distance(all_dates.begin(), it);
        date_indices.clear();
        date_indices.push_back(ind);
        int n_sale_dates_found = 1;
        interp_prices[ind] = prices[0];
        int last_sale_date = dates[n_sales - 1];
        int start_date_index = -1;
        int end_date_index = -1;
        while (all_dates[ind] != last_sale_date && ind < all_dates.size() - 1) {
          if (all_dates[ind] == start_date) {
            start_date_index = ind;
          }
          ++ind;
          int new_date = all_dates[ind];
          double price = -1;
          int* date_it = std::find(dates, dates + n_sales, new_date);
          if (date_it != dates + n_sales) {
            int date_index = std::distance(dates, date_it);
            price = prices[date_index];
            interp_prices[ind] = price;
            date_indices.push_back(ind);
            ++n_sale_dates_found;
          }
          if (all_dates[ind] == end_date) {
            end_date_index = ind;
          }
        }
        
      }
    }
  } else {
    std::cerr << "failed to open the binary file";
    // error
    return 2;
  }
}
