img = $(wildcard build/*.yaml)
src = $(wildcard cmd/fileark/*.go) \
						$(wildcard pkg/cmd/*.go) \
						$(wildcard pkg/fileark/*.go) \
						$(wildcard pkg/satokensource/*.go) \
						$(wildcard pkg/sdlog/*.go)

image.build: $(img) $(src)
	@gcloud container builds submit --config $< . > $@ 2>&1 ; if [ $$? -ne 0 ] ; then rm $@ ; echo "build failed" ; fi

.PHONY: clean
clean:
	@if [ -e image.build ] ; then rm image.build; fi
