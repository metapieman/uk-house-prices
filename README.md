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

## Setting up the data

### Downloading the Land Registry data

To download the Land Registry data for the first time, or to update to the latest data, run the following command from the top level directory of the repository:

<code>make TRY_ALL_UPDATES</code>

(Note: it will take a while to finish if you are running it for the first time.)

The Land Registry updates its data around the end of each month. If the data hasn't changed since the above command was last run, nothing will be downloaded.

### Downloading the Energe Performance Certificate data

The UK Department For Communities and Local Government publishes a dataset containing Energy Performance Certificates (see https://epc.opendatacommunities.org/). Since EPCs contain area information, it is possible to link this dataset with Land Registry data to obtain per-square-metre prices for many properties.

You must download the complete EPC dataset and unzip it into a subdirectory <code>energy-certificates</code> in the top level directory of this repo. Having done so, if you run <code>ls energy-certificates |  head</code> from the top level directory, you should see something like the following:

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

Unfortunately, not all properties appear in the EPC dataset. This means that when creating per-square-metre plots (see below), some sales in the Land Registry data go unused. This seems unavoidable.

## Creating per-square-metre plots

To specify a list of wards and/or postcodes to plot, you must save a JSON file inside <code>plots/per_square_metre/groupings/</code>. You will find two sample JSON files in the repo: <code>ward_example.json</code> and <code>postcode_example.json</code>. The latter file looks like this:
 
```
[
    {
        "name": "Hampstead",
        "type": "first half of postcode",
        "postcode": "NW3"
    },
    {
        "name": "Camden",
        "type": "first half of postcode",
        "postcode": "NW1"
    },
    {
        "name": "Crouch End",
        "type": "first half of postcode",
        "postcode": "N8"
    },
    {
        "name": "Muswell Hill",
        "type": "first half of postcode",
        "postcode": "N10"
    },
    {
        "name": "Highgate",
        "type": "first half of postcode",
        "postcode": "N6"
    }
]

```

The ```name``` field is an arbitrary name to display in the plot legend.

From this JSON file, you can generate PDF files containing per-square-metre plots as follows:

```
make plots/per_square_metre/groupings/postcode_example.[STATISTIC]_[AGE]_[PROPERTY TYPE].pdf
```

Here, replace ```[STATISTIC]``` with ```mean``` or ```median```, ```[AGE]``` with ```period``` or ```newbuild```, and ```[PROPERTY TYPE]``` with ```flat```, ```terraced```, ```semi``` or ```detached```.

To create all possible PDFs with a single command, you could do this:

```
make plots/per_square_metre/groupings/postcode_example.{mean,median}_{period,newbuild}_{flat,terraced,semi,detached}.pdf
```

(You can even parallelize this command by using the ```-j``` option
to ```make```.)

See ```ward_example.json``` for how to plot by ward.

To create your own plots, simply create a JSON file, and run which <code>make</code> command you like on it, as above.

## Creating monthly plots of London statistics

In addition to the plots by ward or postcode, there is special extra functionality to create PDFs of prices over all London boroughs in a large grid. Note that these are *not* per-square-metre prices, they are full prices.

To use this extra functionality, you must have have installed <code>R</code>, along with the <code>dplyr</code>, <code>ggplot2</code> libraries.

To generate pdf plots of the monthly median and mean prices of London
flats and houses by borough, do this:

<code>make plots/london_period_{flats,houses}_{median,mean}.pdf</code>

(You can parallelize this command by using the <code>-j</code> option
to <code>make</code>.)

Here's a sample of what the plots will look like (but note that you will see all boroughs in the plots, not just the small selection shown here):

![London plot sample](/plots.png?raw=true "London plot sample")

Currently, new-build properties are not supported for these plots,
although they are supported for the per-square metre plots.
