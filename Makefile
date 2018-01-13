all:
	./gen-packages.sh

clean:
	$(RM) *.opk
	$(RM) -r tmp
