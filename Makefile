.POSIX:

PREFIX=/usr/local
INCLUDEDIR=$(PREFIX)/include
LIBDIR=$(PREFIX)/lib
PKGCONFIGDIR=$(LIBDIR)/pkgconfig

PICFLAGS=-fPIC
WFLAGS=-Wall
INCLUDES=-Iinclude

SHAREDLIB=libnl-tiny.so
STATICLIB=libnl-tiny.a
PCFILE=libnl-tiny.pc
ALL_LIBS=$(SHAREDLIB) $(STATICLIB)
ALL_INCLUDES=\
	include/netlink-generic.h \
	include/netlink-local.h \
	include/netlink-types.h \
	include/netlink/addr.h \
	include/netlink/attr.h \
	include/netlink/cache-api.h \
	include/netlink/cache.h \
	include/netlink/data.h \
	include/netlink/errno.h \
	include/netlink/genl/ctrl.h \
	include/netlink/genl/family.h \
	include/netlink/genl/genl.h \
	include/netlink/genl/mngt.h \
	include/netlink/handlers.h \
	include/netlink/list.h \
	include/netlink/msg.h \
	include/netlink/netlink-compat.h \
	include/netlink/netlink-kernel.h \
	include/netlink/netlink.h \
	include/netlink/object-api.h \
	include/netlink/object.h \
	include/netlink/socket.h \
	include/netlink/types.h \
	include/netlink/utils.h \
	include/netlink/version.h \
	include/unl.h

LIBNL_SRCS=nl.c handlers.c msg.c attr.c cache.c cache_mngt.c object.c socket.c error.c
GENL_SRCS=genl.c genl_family.c genl_ctrl.c genl_mngt.c unl.c
SRCS=$(LIBNL_SRCS) $(GENL_SRCS)
OBJS=$(SRCS:.c=.o)

-include config.mak

ALL_CFLAGS=$(CFLAGS) $(PICFLAGS) $(WFLAGS) $(INCLUDES)

all: $(ALL_LIBS) $(PCFILE)

clean:
	rm -f $(OBJS) $(ALL_LIBS) $(PCFILE)

.c.o:
	$(CC) $(CPPFLAGS) -c -o $@ $(ALL_CFLAGS) $<


$(SHAREDLIB): $(OBJS)
	$(CC) -shared -o $@ $(LDFLAGS) $(OBJS)

$(STATICLIB): $(OBJS)
	rm -f $@
	$(AR) -rc $@ $(OBJS)

$(PCFILE): $(PCFILE).in
	sed 's,@prefix@,$(prefix),g' $(PCFILE).in > $@

install: $(ALL_LIBS) $(ALL_INCLUDES) $(PCFILE)
	mkdir -p "$(DESTDIR)$(INCLUDEDIR)/libnl-tiny/netlink/genl"
	for f in $(ALL_INCLUDES); do \
		f="$${f#include/}"; \
		cp "include/$$f" "$(DESTDIR)$(INCLUDEDIR)/libnl-tiny/$${f%/*}"; \
	done
	mkdir -p "$(DESTDIR)$(LIBDIR)"
	for f in $(ALL_LIBS); do \
		cp "$$f" "$(DESTDIR)$(LIBDIR)/"; \
	done
	mkdir -p "$(DESTDIR)$(PKGCONFIGDIR)"
	cp "$(PCFILE)" "$(DESTDIR)$(PKGCONFIGDIR)/"

.PHONY: all clean install
