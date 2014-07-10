prefix=/usr/local
CC=gcc
WFLAGS=-Wall
CFLAGS?=-O2
INCLUDES=-Iinclude

LIBNAME=libnl-tiny.so

-include config.mak

all: $(LIBNAME)

%.o: %.c
	$(CC) $(WFLAGS) -c -o $@ $(INCLUDES) $(CFLAGS) $<

LIBNL_OBJ=nl.o handlers.o msg.o attr.o cache.o cache_mngt.o object.o socket.o error.o
GENL_OBJ=genl.o genl_family.o genl_ctrl.o genl_mngt.o unl.o

$(LIBNAME): $(LIBNL_OBJ) $(GENL_OBJ)
	$(CC) -shared -o $@ $^

libnl-tiny.a: $(LIBNL_OBJ) $(GENL_OBJ)
	ar rc $@ $^
	ranlib libnl-tiny.a

libnl-tiny.pc: libnl-tiny.pc.in
	sed s,@prefix@,$(prefix),g $< > $@

