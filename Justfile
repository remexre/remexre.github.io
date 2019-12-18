build-local:
	zola build -u /blog/
watch-local:
	watchexec -w content -w static -w templates -- just build-local
