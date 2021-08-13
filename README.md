# uk-house-prices

## Short description

This is a Makefile-based project to study UK house prices. It uses Land Registry data for paid prices, and (optionally) Energy Performance Certificate data for area information. Currently, it can plot statistics such as median/mean prices and transaction volumes for London boroughs. It may also be useful for other regions, simply as a tool for maintaining an up-to-date Land Registry dataset.

## Requirements

- GNU Make
- Bash shell
- R with dplyr, ggplot2 libraries installed
- Python with numpy, pandas libraries installed

## Usage

### Downloading the Land Registry data

To download the Land Registry data for the first time, or to update to the latest data, simply do this:

<code>make TRY_ALL_UPDATES</code>

The Land Registry updates its data around the end of each month. If the data hasn't changed since the above command was last run, nothing will be downloaded.

### Creating monthly plots of London statistics

To generate pdf plots of the monthly median and mean prices of London
flats and houses by borough, do this:

<code>make plots/london_period_{flats,houses}_{median,mean}.pdf

(You can parallelize this command by using the <code>-j</code> option
to <code>make</code>.)

Here's a sample of what the plots will look like:

![London plot sample](/plots.png?raw=true "London plot sample")

Currently, new-build properties are not supported for the above plots,
although they are supported for the per-square metre plots (see
below).

### Creating London per-square-metre plots

The UK Department For Communities and Local Government publishes a dataset containing Energy Performance Certificates (see ```https://epc.opendatacommunities.org/```). Since EPCs contain area information, it is possible to link this dataset with Land Registry data to obtain per-square-metre prices for many properties.

**Note** Not all properties appear in the EPC dataset. This means, of course, that when creating per-square-metre plots (see below), some sales in the Land Registry data go unused.

To plot per-square-metre statistics, you must download the complete EPC dataset and unzip it into a subdirectory <code>energy-certificates</code> in the top level directory of this repo. Then, from the top level directory, if you do <code>ls energy-certificates |  head</code>, you should see something like:

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

<code>make plots/per_square_metre/london_[STATISTIC]\_[AGE]\_[PROPERTY TYPE].pdf </code>

Here, replace ```[STATISTIC]``` with ```mean``` or ```median```, ```[AGE]``` with ```period``` or ```newbuild```, and ```[PROPERTY TYPE]``` with ```flat```, ```terraced```, ```semi``` or ```detached```.
