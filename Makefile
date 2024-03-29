SHELL := /bin/bash

.SECONDARY:

.SECONDEXPANSION:

ALL_YEARS=$(shell ./scripts/all-years)

ALL_REDUCED_FILES=$(foreach year,$(ALL_YEARS),data/reduced/$(year).csv)
REDUCED_FILES: $(ALL_REDUCED_FILES)

ALL_AREA_DATA_FILES=$(foreach year,$(ALL_YEARS),data/enhanced-with-energy-data/$(year).csv.gz)

# Open an exploratory iPython session with area data preloaded
AREA_DATA_IPY: $(ALL_AREA_DATA_FILES)
	./explore-area-data $^

# E.g.
#
# make data/reduced/2015.txt
#
# These files are sorted, for easy merging.
data/reduced/%.csv:  data/latest/pp-%.csv
	mkdir -p data/reduced
	scripts/reduce-data.py $< ./header.csv | sed 's/ 00:00//g'>$@.tmp
	sort $@.tmp > $@.tmp.sorted
	mv $@.tmp.sorted $@
	rm $@.tmp

# E.g.: make plots/london_period_flats_median.pdf
plots/london_period_flats_%.pdf plots/london_period_houses_%.pdf:  data/summaries_by_stat/%.csv
	mkdir -p plots
	Rscript scripts/plot-london.R $*
	mv plots/london_period_flats_$*.tmp.pdf plots/london_period_flats_$*.pdf
	mv plots/london_period_houses_$*.tmp.pdf plots/london_period_houses_$*.pdf
	-rm Rplots.pdf

ALL_YEARLY_SUMMARY_FILES=$(foreach year,$(ALL_YEARS),data/summaries_by_year/$(year).csv)
.PHONY: ALL_YEARLY_SUMMARIES
ALL_YEARLY_SUMMARIES:  $(ALL_YEARLY_SUMMARY_FILES)

STATS=mean len median
ALL_STAT_SUMMARY_FILES=$(foreach stat,$(STATS),data/summaries_by_stat/$(stat).csv)
.PHONY: ALL_STAT_SUMMARIES
ALL_STAT_SUMMARY_FILES:  $(ALL_STAT_SUMMARY_FILES)

data/summaries_by_stat/%.csv:  $(ALL_YEARLY_SUMMARY_FILES)
	mkdir -p data/summaries_by_stat
        # the grep -v \,\, removes missing prices
	head -n 1 $< >$@.tmp && grep -h -e $* $^ | grep -v \,\, >>$@.tmp
	mv $@.tmp $@

data/summaries_by_year/%.csv:  data/latest/pp-%.csv
	mkdir -p data/summaries_by_year
	./scripts/write_summary.py $< ./header.csv  > $@.tmp
	mv $@.tmp $@


ALL_ENHANCED=$(foreach year,$(ALL_YEARS),data/enhanced-with-energy-data/$(year).csv.gz)

# % should be STAT_AGE_TYPE
#
# E.g.:
#
# make plots/per_square_metre/groupings/hampstead_and_highgate.mean_period_flat.pdf
plots/per_square_metre/groupings/%.pdf:  \
  $(ALL_ENHANCED) \
  plots/per_square_metre/groupings/$$(shell basename $$@ | sed 's/\.[^\.]\+\.pdf//').json
	scripts/plot-grouping-per-square-metre $@.tmp.pdf $(ALL_ENHANCED)
	mv $@.tmp.pdf $@

ALL_SUMMARIES_PER_SQUARE_METRE=$(foreach year,$(ALL_YEARS),data/summaries-by-square-metre/$(year).csv)

# % should be STAT_AGE_TYPE
#
# E.g.:
#
# make plots/per_square_metre/vs_size/hampstead_and_highgate.mean_period_flat.pdf
plots/per_square_metre/vs_size/%.pdf:  \
  $(ALL_ENHANCED) \
  plots/per_square_metre/groupings/$$(shell basename $$@ | sed 's/[0-9]\{8\}_[0-9]\{8\}\.//' | sed 's/\.[^\.]\+\.pdf//').json
	scripts/plot-per-square-metre-vs-size $@.tmp.pdf $(ALL_ENHANCED)
	mv $@.tmp.pdf $@


# % should be STAT_AGE_TYPE
#
# E.g.:
#
# make plots/per_square_metre/london_mean_period_flat.pdf
plots/per_square_metre/london_%.pdf:  $(ALL_SUMMARIES_PER_SQUARE_METRE)
	mkdir -p $$(dirname $@)
	scripts/plot-london-per-square-metre $@.tmp.pdf $$(echo $* | tr '_' ' ') $^
	mv $@.tmp.pdf $@


# E.g., make data/summaries-by-square-metre/2017.csv
data/summaries-by-square-metre/%.csv:  data/enhanced-with-energy-data/%.csv.gz
	mkdir -p $$(dirname $@)
	scripts/summarize-by-square-metre $^ >$@.tmp
	mv $@.tmp $@

# E.g., make data/enhanced-with-energy-data/2017.csv.gz
data/enhanced-with-energy-data/%.csv.gz:  data/latest/pp-%.csv data/full-addresses/%.csv.gz energy-certificates/reduced.csv.gz
	mkdir -p $$(dirname $@)
	scripts/join-lr-and-energy-data ./header.csv data/enhanced-with-energy-data/$*.csv $^
	gzip -f data/enhanced-with-energy-data/$*.csv

# For a given Land Registry yearly file, extract full
# addresses. Number of lines will be the same.
#
# E.g., make data/full-addresses/2017.csv.gz
data/full-addresses/%.csv.gz:  data/latest/pp-%.csv
	mkdir -p $$(dirname $@)
	set -o pipefail && \
            scripts/normalize-lr-addresses ./header.csv data/latest/pp-$*.csv | \
            tr ',' ' ' | sed 's/\ \+/\ /g' > data/full-addresses/$*.csv
	gzip -f data/full-addresses/$*.csv

# Combined energy certificate data for all boroughs, with only the
# information we need: FULL_ADDRESS, POSTCODE, PROPERTY_TYPE,
# TOTAL_FLOOR_AREA
energy-certificates/reduced.csv.gz:  $$(shell scripts/all-reduced-energy-files)
	scripts/concat-reduced-energy-files energy-certificates/reduced.csv $^
	gzip -f energy-certificates/reduced.csv

# For a given certificates file, produce a reduced version containing
# only the information we need. Number of lines will be the same.
#
# E.g.:
#
# make energy-certificates/domestic-E09000017-Hillingdon/reduced.csv.gz
energy-certificates/%/reduced.csv.gz:  energy-certificates/%/certificates.csv energy-certificates/%/addresses.csv.gz
	scripts/create-reduced-energy-file \
           energy-certificates/$*/reduced.csv \
	   energy-certificates/$*/certificates.csv \
           energy-certificates/$*/addresses.csv.gz
	gzip -f energy-certificates/$*/reduced.csv

# For a given certificates file, produce a file containing the full
# address for each line.
#
# E.g.:
#
# make energy-certificates/domestic-E09000017-Hillingdon/addresses.csv.gz
energy-certificates/%/addresses.csv.gz:  energy-certificates/%/certificates.csv
	set -o pipefail && \
            scripts/extract-address-fields-from-energy-csv $< | tr ',' ' ' | sed 's/\ \+/\ /g' | \
               tr '[:lower:]' '[:upper:]' > energy-certificates/$*/addresses.csv
	gzip -f energy-certificates/$*/addresses.csv

# E.g.: make TRY_UPDATE_2016
.PHONY: TRY_UPDATE_%
TRY_UPDATE_%:
	mkdir -p data/latest
	mkdir -p data/land-registry-mirror
	cd data/land-registry-mirror && ../../scripts/try-update $*

ALL_UPDATES=$(foreach year,$(ALL_YEARS),TRY_UPDATE_$(year))
.PHONY: TRY_ALL_UPDATES
TRY_ALL_UPDATES:  $(ALL_UPDATES)
