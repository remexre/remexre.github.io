build:
	zola build --drafts -u /blog/
watch:
	watchexec -w content -w static -w templates -- $(MAKE) build
.PHONY: build watch
