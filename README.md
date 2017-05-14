# uk-house-prices
Makefile-based project to study UK house prices using Land Registry data. Currently produces plots for London only, but may still be useful simply as a tool for maintaining an up-to-date Land Registry dataset.

## Requirements

- GNU Make
- Bash shell
- R with dplyr, ggplot2 libraries installed
- Python with numpy, pandas libraries installed
- Reasonably new g++ (must support '--std c++0x' option)

## Usage

### Downloading the Land Registry data

To download the Land Registry data for the first time, or to update to the latest data, simply do this:

<code>make TRY_ALL_UPDATES</code>

The Land Registry updates its data around the end of each month. If the data hasn't changed since the above command was last run, nothing will be downloaded.

### Creating monthly plots of London statistics

To generate pdf plots of the monthly median price of London flats/houses, do this:

<code>make plots/london_period_flats_median.pdf plots/london_period_houses_median.pdf</code>

You can replace 'median' with 'mean' or 'len' to plot monthly means or sales counts respectively.

### Creating London per-square-metre plots

The UK Department For Communities and Local Government publishes a dataset containing Energy Performance Certificate data. Since EPCs contain area data, it is possible to link this with Land Registry data to obtain per-square-metre prices for many properties. Note that not all properties appear in the EPC dataset, so when creating per-square-metre statistics it is necessary to throw away some of the Land Registry data.

To plot per-square-metre statistics, you must download the complete EPC dataset and unzip it into a subdirectory <code>energy-certificates</code> in the top level directory of this repo. Then, from the top level directory of this repo, if you do <code>ls energy-certificates |  head</code>, you should see something like:

```
domestic-E06000001-Hartlepool  
domestic-E06000002-Middlesbrough  
domestic-E06000003-Redcar-and-Cleveland  
domestic-E06000004-Stockton-on-Tees
domestic-E06000005-Darlington
domestic-E06000006-Halton
domestic-E06000007-Warrington
domestic-E06000008-Blackburn-with-Darwen
domestic-E06000009-Blackpool
domestic-E06000010-Kingston-upon-Hull-City-of
```
Having done that, you can then create per-square-metre plots as follows:

<code>make data/plots/per_square_metre/london_[STATISTIC]\_[AGE]\_[PROPERTY TYPE].pdf </code>

Here, replace ```[STATISTIC]``` with ```mean``` or ```median```, ```[AGE]``` with ```period``` or ```newbuild```, and ```[PROPERTY TYPE]``` with ```flat```, ```terraced```, ```semi``` or ```detached```.
