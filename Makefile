SHELL := /bin/bash

.SECONDEXPANSION:

ALL_YEARS=$(shell ./scripts/all-years)

plots/london_period_flats.pdf plots/london_period_houses.pdf:  data/summaries_by_stat/median.csv
	mkdir -p plots
	Rscript scripts/plot-london.R
	mv plots/london_period_flats.tmp.pdf plots/london_period_flats.pdf
	mv plots/london_period_houses.tmp.pdf plots/london_period_houses.pdf
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


data/latest/pp-%.csv:  TRY_UPDATE_%
	@echo making $@

# E.g.: make TRY_UPDATE_2016
.PHONY: TRY_UPDATE_%
TRY_UPDATE_%:
	mkdir -p data/latest
	cd data/latest && ../../scripts/try-update $*

ALL_UPDATES=$(foreach year,$(ALL_YEARS),TRY_UPDATE_$(year))
.PHONY: TRY_ALL_UPDATES
TRY_ALL_UPDATES:  $(ALL_UPDATES)
