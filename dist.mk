# Make distribution RPM
# Thomas Perl <m@thp.io>
# Required packages (build-dependencies): rpm

SPECSRC := rpm/harbour-org.gpodder.sailfish.spec

RPMBUILD_ROOT := ~/rpmbuild
NAME := $(shell rpmspec --query --queryformat='%{name}' $(SPECSRC))
VERSION := $(shell rpmspec --query --queryformat='%{version}' $(SPECSRC))
RELEASE := $(shell rpmspec --query --queryformat='%{release}' $(SPECSRC))
SOURCES := README gpodder-core podcastparser gpodder-ui-qml qml
RPMSRC := $(wildcard rpm/*.png rpm/*.desktop)

TARNAME := $(NAME)-$(VERSION).tar.gz
SPECNAME := $(NAME)-$(VERSION).spec
RPMNAME := $(NAME)-$(VERSION)-$(RELEASE).noarch.rpm

all: rpm

rpm: $(SPECNAME) $(TARNAME)
	mkdir -p $(RPMBUILD_ROOT)/SOURCES
	cp $(RPMSRC) $(TARNAME) $(RPMBUILD_ROOT)/SOURCES/
	rpmbuild -bb --clean $(SPECNAME)
	cp $(RPMBUILD_ROOT)/RPMS/noarch/$(RPMNAME) .

$(TARNAME):
	rm -rf tmp
	mkdir -p tmp/$(NAME)-$(VERSION)
	cp -rpv $(SOURCES) tmp/$(NAME)-$(VERSION)/
	tar -C tmp -czvf $@ $(NAME)-$(VERSION)

$(SPECNAME): rpm/$(NAME).spec
	cp $< $@

clean:
	rm -rf $(SPECNAME) $(TARNAME) tmp

distclean: clean
	rm -f $(RPMNAME)

.DEFAULT: all
.PHONY: all rpm clean distclean
