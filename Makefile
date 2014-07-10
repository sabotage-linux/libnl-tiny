prefix=/usr/local
libdir=$(prefix)/lib
includedir=$(prefix)/include

CC=gcc
WFLAGS=-Wall
CFLAGS?=-O2
INCLUDES=-Iinclude

SHAREDLIB=libnl-tiny.so
STATICLIB=libnl-tiny.a
PCFILE=libnl-tiny.pc
ALL_LIBS=$(SHAREDLIB) $(STATICLIB)
ALL_INCLUDES=$(sort $(wildcard include/*.h include/*/*.h include/*/*/*.h))

LIBNL_SRCS=nl.c handlers.c msg.c attr.c cache.c cache_mngt.c object.c socket.c error.c
GENL_SRCS=genl.c genl_family.c genl_ctrl.c genl_mngt.c unl.c
SRCS=$(LIBNL_SRCS) $(GENL_SRCS)
OBJS=$(SRCS:.c=.o)

PICFLAGS=-fPIC

-include config.mak

all: $(ALL_LIBS) $(PCFILE)

install: $(ALL_LIBS:%=$(DESTDIR)$(libdir)/%) \
         $(ALL_INCLUDES:include/%=$(DESTDIR)$(includedir)/libnl-tiny/%) \
         $(PCFILE:%=$(DESTDIR)$(libdir)/pkgconfig/%)

clean:
	rm -f $(OBJS) $(ALL_LIBS) $(PCFILE)

%.o: %.c
	$(CC) $(CPPFLAGS) -c -o $@ $(INCLUDES) $(CFLAGS) $(PICFLAGS) $<


$(SHAREDLIB): $(OBJS)
	$(CC) -shared -o $@ $^ $(LDFLAGS)

$(STATICLIB): $(OBJS)
	rm -f $@
	ar rc $@ $^
	ranlib $@

$(PCFILE): $(PCFILE).in
	sed s,@prefix@,$(prefix),g $< > $@


$(DESTDIR)$(includedir)/libnl-tiny/%: include/%
	install -D -m 644 $< $@

$(DESTDIR)$(libdir)/%: %
	install -D -m 644 $< $@

$(DESTDIR)$(libdir)/pkgconfig/%: %
	install -D -m 644 $< $@


.PHONY: all clean install
