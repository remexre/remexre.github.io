all: build
watch TARGET="all":
	watchexec -cr "just {{TARGET}}"

build:
	gutenberg build
serve PORT="8080":
	gutenberg serve --port {{PORT}}
