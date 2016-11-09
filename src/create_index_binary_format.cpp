#include <cstdint>
#include <cstdlib>
#include <exception>
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
  int bytes_read = fread((void*) &n_sales, 4, 1, handle);
  if (feof(handle)) {
    if (bytes_read != 0) {
      std::cerr
        << "read_record(): unexpected end of file with " << bytes_read
        << " bytes read" << std::endl;
      return -6;
    }
    return 0;
  }
  if (bytes_read != 4) {
    std::cerr
      << "read_record(): failed to read initial 4 bytes of record" << std::endl;
    return -1;
  }
  if (n_sales > max_num_sales) {
    std::cerr
      << "read_record(): n_sales " << n_sales << " exceeds max_num_sales "
      << max_num_sales << std::endl;
    return -2;
  }
  int bytes_read = fread((void*) postcode, 8, 1, handle);
  if (bytes_read != 8) {
    std::cerr
      << "read_record(): failed to read 8 byte postcode string" << std::endl;
    return -3;
  }
  int bytes_read  = fread((void*) dates, 4, n_sales, handle);
  if (bytes_read != 4*n_sales) {
    std::cerr
      << "read_record(): failed to read " << n_sales << " dates" << std::endl;
    return -4;
  }
  int bytes_read  = fread((void*) prices, 4, n_sales, handle);
  if (bytes_read != 4*n_sales) {
    std::cerr
      << "read_record(): failed to read " << n_sales << " prices" << std::endl;
    return -5;
  }
  return n_sales;
}

int main(int argc, char*[] argv) {
  std::string dates_file(argv[1]);
  std::string binary_data_file(argv[2]);
  std::vector<int> dates = get_all_dates(dates_file);
  int start_date = atoi(argv[3]);
  int end_date = atoi(argv[4]);
  FILE* handle = fopen (binary_data_file.c_str(), "rb");
  if (handle != NULL)
  {
    // do stuff
  } else {
    throw std::runtime_error("failed to open the binary file");
  }
}
