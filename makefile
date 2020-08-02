all: 
	bundle exec jekyll build

dev: serve-watch-drafts

serve:
	bundle exec jekyll serve

serve-watch:
	bundle exec jekyll serve --watch

serve-watch-drafts:
	bundle exec jekyll serve --watch --drafts