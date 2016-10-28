# uk-house-prices
Makefile-based project to study UK house prices using Land Registry data.

To generate pdf plots of London flats/houses, do this:

<code>make plots/london_period_flats.pdf plots/london_period_houses.pdf</code>

To update the dataset (if an update exists), do this:

<code>make TRY_ALL_UPDATES</code>

Requirements:

- GNU Make
- Bash shell
- R with dplyr, ggplot2 libraries installed
- Python with numpy, pandas libraries installed

