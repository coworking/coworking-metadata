YAML2JSON := perl -MYAML::XS -MJSON::XS \
        -e 'print encode_json YAML::XS::LoadFile(shift)'

all: metadata.yaml metadata.json

metadata.yaml: sites.yaml
	./bin/spider $< > $@

metadata.json: metadata.yaml
	$(YAML2JSON) $< > $@

update1:
	./bin/update-metadata-from-spreadsheet

clean purge:
	rm -f metadata.yaml metadata.json
