ERL_COMPILE_FLAGS += +warn_exported_vars +warn_unused_import +warn_untyped_record +warn_missing_spec +debug_info

POWER_MODULES = powerset

all: 	power script

clean:
	rm -rf *.beam run.sh

power:	$(POWER_MODULES:%=%.beam)

script: run.sh

run.sh:
	printf "#%c/bin/bash\n \
	        erl -noinput -s powerset run -s init stop" ! \
	      > run.sh
	chmod +x run.sh

%.beam: %.erl
	erlc -W $(ERL_COMPILE_FLAGS) $<