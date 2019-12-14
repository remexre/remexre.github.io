watch-local:
	watchexec -w content -w static -w templates -- zola build -u /blog/
