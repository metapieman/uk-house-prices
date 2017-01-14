# uk-house-prices
Makefile-based project to study UK house prices using Land Registry data.

## Requirements

- GNU Make
- Bash shell
- R with dplyr, ggplot2 libraries installed
- Python with numpy, pandas libraries installed
- Reasonably new g++ (must support '--std c++0x' option)

## Usage

To create/update the dataset from the Land Registry website, do this:

<code>make TRY_ALL_UPDATES</code>

The Land Registry updates its datasets around the end of each month. If the data hasn't changed since the command was last run, nothing will be downloaded. 

To generate pdf plots of the monthly median price of London flats/houses, do this:

<code>make plots/london_period_flats_median.pdf plots/london_period_houses_median.pdf</code>

You can replace 'median' with 'mean' or 'len' to plot monthly means or sales counts respectively.
