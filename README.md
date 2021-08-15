# uk-house-prices

The aim of this project is to make it easy to compare property prices per square metre across [United Kingdom wards](https://en.wikipedia.org/wiki/Wards_and_electoral_divisions_of_the_United_Kingdom) or postcodes.

Here's an example, showing the median price per square metre for period flats across several wards in the London borough of Camden:

![camden](/camden_flats_by_ward.png?raw=true "Camden flats by ward")

The code relies on the following data sources:

- Land Registry data for sold prices
- Energy Performance Certificate data for area information
- The ONS Postcode Directory (ONSPD)
 
The project is a little unusual: it is based around the GNU Make tool, which is used both for downloading Land Registry data, and for creating PDF plots.

## Requirements

- GNU Make
- Bash shell
- Python with numpy, pandas libraries installed

## Usage

### Downloading the Land Registry data

To download the Land Registry data for the first time, or to update to the latest data, simply do this:

<code>make TRY_ALL_UPDATES</code>

The Land Registry updates its data around the end of each month. If the data hasn't changed since the above command was last run, nothing will be downloaded.

### Creating monthly plots of London statistics

In addition to the plots by ward or postcode, there is special extra functionality to create PDFs of prices over all London boroughs in a large grid. Note that these are *not* per-square-metre prices, they are full prices.

To use this extra functionality, you must have have installed <code>R</code>, along with the <code>dplyr</code>, <code>ggplot2</code> libraries.

To generate pdf plots of the monthly median and mean prices of London
flats and houses by borough, do this:

<code>make plots/london_period_{flats,houses}_{median,mean}.pdf</code>

(You can parallelize this command by using the <code>-j</code> option
to <code>make</code>.)

Here's a sample of what the plots will look like (but note that you will see all boroughs in the plots, not just the small selection shown here):

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
