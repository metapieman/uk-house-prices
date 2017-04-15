SHELL := /bin/bash

.SECONDEXPANSION:

ALL_YEARS=$(shell ./scripts/all-years)

ALL_REDUCED_FILES=$(foreach year,$(ALL_YEARS),data/reduced/$(year).csv)
REDUCED_FILES: $(ALL_REDUCED_FILES)

# TODO: Change to version with postcode
# E.g.: make data/index_data/UK_20160101_20160201.from_python.csv
data/index_data/%.from_python.csv:   data/index_data/multisales.csv.gz
	mkdir -p data/index
	zcat $< | scripts/create-index.py $* > $@.tmp
	mv $@.tmp $@

# # E.g., make data/index_values/NorthWestLondon/mean/monthly/collected.csv
data/index_values/%/collected.csv:  $$(shell scripts/get-collected-dependencies.sh $$*)
	mkdir -p $$(dirname $@)
	scripts/gather-stats.py $^ > $@.tmp
	mv $@.tmp $@

# E.g., make data/index_values/NorthWestLondon/mean/20160101_20160201.json
data/index_values/%.json:  $$(shell scripts/get-index-dependencies.py $$*)
	mkdir -p $$(dirname $@)
	scripts/calculate-index.py $^ $$(basename $$(dirname $@)) > $@.tmp
	mv $@.tmp $@

# E.g.: make data/index_data/20160101_20160201.csv
data/index_data/%.csv:  data/index_data/multisales.binary \
                        bin/create_index_binary_format \
                        data/index_data/dates.txt
	mkdir -p $$(dirname $@)
	bin/create_index_binary_format data/index_data/dates.txt \
            data/index_data/multisales.binary \
            $(shell echo $* | tr -s '_' ' ') > $@.tmp
	mv $@.tmp $@

data/index_data/dates.txt:  data/latest/$$(shell ls data/latest  | sort -r | head -n 1)
	LAST_DATE=$$(cut -d ',' -f 3 data/latest/pp-2016.csv | \
                     cut -d ' ' -f 1 | \
                     tr -d '"-' | \
                     sort -u | \
                     tail -n 1) && \
          END_DATE=$$(date +%Y%m%d -d "$$LAST_DATE +1 day") && \
          scripts/create-dates.sh $$END_DATE > $@.tmp
	mv $@.tmp $@

bin/create_index_binary_format:  src/create_index_binary_format.cpp
	mkdir -p $$(dirname $@)
	g++ --std c++0x $< -o $@

data/index_data/multisales.binary: data/reduced/all.csv.gz
	mkdir -p data/index_data
	(set -o pipefail; zcat $< | scripts/get-multisales-binary-format.py $@.tmp)
	mv $@.tmp $@

data/index_data/multisales.csv.gz: data/reduced/all.csv.gz
	mkdir -p data/index_data
	(set -o pipefail; zcat $< | scripts/get-multisales.py | gzip > $@.tmp)
	mv $@.tmp $@

data/reduced/all.csv.gz:  $(ALL_REDUCED_FILES)
	sort --merge $^ | gzip > $@.tmp
	mv $@.tmp $@

# E.g.:make data/addresses/2015.txt
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

# E.g., make data/summaries-by-square-metre/2017.csv
data/summaries-by-square-metre/%.csv:  data/enhanced-with-energy-data/%.csv.gz
	mkdir -p $$(dirname $@)
	scripts/summarize-by-square-metre $^ >$@.tmp
	mv $@.tmp $@

# E.g., make data/enhanced-with-energy-data/2017.csv.gz
data/enhanced-with-energy-data/%.csv.gz:  data/latest/pp-%.csv data/full-addresses/%.csv.gz energy-certificates/reduced.csv.gz
	mkdir -p $$(dirname $@)
	scripts/join-lr-and-energy-data ./header.csv data/enhanced-with-energy-data/$*.csv $^
	gzip data/enhanced-with-energy-data/$*.csv

# E.g., make data/full-addresses/2017.csv.gz
data/full-addresses/%.csv.gz:  data/latest/pp-%.csv
	mkdir -p $$(dirname $@)
	set -o pipefail && \
            scripts/normalize-lr-addresses ./header.csv data/latest/pp-$*.csv | \
            tr ',' ' ' | sed 's/\ \+/\ /g' > data/full-addresses/$*.csv
	gzip data/full-addresses/$*.csv

# Combined energy certificate data for all boroughs, with only the
# information we need.
energy-certificates/reduced.csv.gz:  $$(shell scripts/all-reduced-energy-files)
	scripts/concat-reduced-energy-files energy-certificates/reduced.csv $^
	gzip energy-certificates/reduced.csv

energy-certificates/%/reduced.csv.gz:  energy-certificates/%/certificates.csv energy-certificates/%/addresses.csv.gz
	scripts/create-reduced-energy-file \
           energy-certificates/$*/reduced.csv \
	   energy-certificates/$*/certificates.csv \
           energy-certificates/$*/addresses.csv.gz
	gzip energy-certificates/$*/reduced.csv

energy-certificates/%/addresses.csv.gz:  energy-certificates/%/certificates.csv
	set -o pipefail && \
            scripts/extract-address-fields-from-energy-csv $< | tr ',' ' ' | sed 's/\ \+/\ /g' | \
               tr '[:lower:]' '[:upper:]' > energy-certificates/$*/addresses.csv
	gzip energy-certificates/$*/addresses.csv

# E.g.: make TRY_UPDATE_2016
.PHONY: TRY_UPDATE_%
TRY_UPDATE_%:
	mkdir -p data/latest
	cd data/latest && ../../scripts/try-update $*

ALL_UPDATES=$(foreach year,$(ALL_YEARS),TRY_UPDATE_$(year))
.PHONY: TRY_ALL_UPDATES
TRY_ALL_UPDATES:  $(ALL_UPDATES)
