CFLAGS=-Wextra -Wall -Wno-unused -pedantic -std=c99 -DNDEBUG -O3
#CFLAGS=-Wextra -Wall -Wno-unused -pedantic -std=c99 -g3 -DNDEBUG
#CFLAGS=-Wextra -Wall -Wno-unused -pedantic -std=c99 -g3
#CFLAGS=-Wextra -Wall -Wno-unused -pedantic -std=c99 -DNDEBUG -g3 -pg -fprofile-arcs -ftest-coverage -static
OBJECTS=qdpll_main.o qdpll_app.o qdpll.o qdpll_mem.o qdpll_dep_man_qdag.o qdpll_pqueue.o

MAJOR=1
MINOR=0
VERSION=$(MAJOR).$(MINOR)

TARGETS:=qdpll_main.o qdpll_app.o libqdpll.a

UNAME:=$(shell uname)

ifeq ($(UNAME), Darwin)
# Mac OS X
SONAME=-install_name
TARGETS+=libqdpll.$(VERSION).dylib
else
SONAME=-soname
TARGETS+=libqdpll.so.$(VERSION)
endif

.SUFFIXES: .c .o .fpico

.c.fpico:
	$(CC) $(CFLAGS) -fPIC -c $< -o $@

.c.o:
	$(CC) $(CFLAGS) -c $< -o $@

depqbf: $(TARGETS)
	$(CC) $(CFLAGS) qdpll_main.o qdpll_app.o -L. -lqdpll -o depqbf

qdpll_main.o: qdpll_main.c qdpll.h

qdpll_app.o: qdpll_app.c qdpll_internals.h qdpll.h qdpll_exit.h qdpll_config.h

qdpll.o: qdpll.c qdpll_internals.h qdpll.h qdpll_mem.h qdpll_pcnf.h qdpll_exit.h \
qdpll_stack.h qdpll_dep_man_generic.h qdpll_dep_man_qdag.h \
qdpll_config.h qdpll_dep_man_qdag_types.h qdpll_pqueue.h

qdpll.fpico: qdpll.c qdpll_internals.h qdpll.h qdpll_mem.h qdpll_pcnf.h qdpll_exit.h \
qdpll_stack.h qdpll_dep_man_generic.h qdpll_dep_man_qdag.h \
qdpll_config.h qdpll_dep_man_qdag_types.h qdpll_pqueue.h

qdpll_mem.o: qdpll_mem.c qdpll_mem.h qdpll_exit.h

qdpll_mem.fpico: qdpll_mem.c qdpll_mem.h qdpll_exit.h

qdpll_pqueue.o: qdpll_pqueue.c qdpll_pqueue.h qdpll_mem.h qdpll_exit.h

qdpll_pqueue.fpico: qdpll_pqueue.c qdpll_pqueue.h qdpll_mem.h qdpll_exit.h

qdpll_dep_man_qdag.o: qdpll_dep_man_qdag.c qdpll_pcnf.h qdpll_exit.h \
qdpll_dep_man_generic.h qdpll_dep_man_qdag.h qdpll_config.h \
qdpll.h qdpll_dep_man_qdag_types.h qdpll_stack.h \
qdpll_internals.h

qdpll_dep_man_qdag.fpico: qdpll_dep_man_qdag.c qdpll_pcnf.h qdpll_exit.h \
qdpll_dep_man_generic.h qdpll_dep_man_qdag.h qdpll_config.h \
qdpll.h qdpll_dep_man_qdag_types.h qdpll_stack.h \
qdpll_internals.h

libqdpll.a: qdpll.o qdpll_pqueue.o qdpll_mem.o qdpll_dep_man_qdag.o
	ar rc $@ $^
	ranlib $@

libqdpll.so.$(VERSION): qdpll.fpico qdpll_pqueue.fpico qdpll_mem.fpico qdpll_dep_man_qdag.fpico
	$(CC) -shared -Wl,$(SONAME),libqdpll.so.$(MAJOR) $^ -o $@

libqdpll.$(VERSION).dylib: libqdpll.so.$(VERSION)
	cp $< $@

clean:
	rm -f *.so.$(VERSION) *.dylib *.fpico *.a *.o *.gcno *.gcda *.gcov *~ gmon.out depqbf
