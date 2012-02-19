SPREADSHEET = data/coworking-app-data/sheet1.csv
YAML2JSON := perl -MYAML::XS -MJSON::XS \
        -e 'print encode_json YAML::XS::LoadFile(shift)'

all: metadata.yaml metadata.json metadata.jsonp

metadata.yaml: $(SPREADSHEET)
	./bin/update-metadata-from-spreadsheet $@ $<

metadata.json: metadata.yaml
	$(YAML2JSON) $< > $@

metadata.jsonp: metadata.json
	echo 'Coworking.add_metadata(' > $@
	./bin/filter-json $< geo >> $@
	echo '' >> $@
	echo ');' >> $@

spider: sites.yaml
	#./bin/spider $< > $@
