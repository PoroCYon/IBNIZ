# For normal builds; remove -DX11 -lX11 from flags if you don't have X11

# vars

CC=gcc
EXE=ibniz
OBJ=obj
BIN=bin
SRC=src
FLAGS=`sdl-config --libs --cflags` -DX11 -lX11
LIBS=-lm
OSFLAG=-Os
O3FLAG=-O3

# targets

debug: all
debug: FLAGS += -g3 -DDEBUG
debug: OSFLAG =
debug: O3FLAG =

release: all
release: FLAGS += -DRELEASE -O3

nox11: all
nox11: FLAGS = `sdl-config --libs --cflags`

makeobjdirs:
	@if ! [ -d "$(BIN)" ]; then	mkdir "$(BIN)"; fi
	@if ! [ -d "$(OBJ)" ]; then	mkdir "$(OBJ)"; fi
cleanbins:
	@rm -f "$(BIN)/*"

runtest: all bin/vmtest
	bin/vmtest

# bins

all: makeobjdirs cleanbins \
  $(OBJ)/ui_sdl.o $(OBJ)/vm_slow.o \
  $(OBJ)/clipboard.o $(OBJ)/compiler.o
	$(CC) $(OSFLAG) -s \
        "$(OBJ)/ui_sdl.o" "$(OBJ)/vm_slow.o" \
        "$(OBJ)/clipboard.o" "$(OBJ)/compiler.o" \
        -o $(BIN)/$(EXE) $(FLAGS) $(LIBS)

$(BIN)/vmtest: makeobjdirs cleanbins \
  $(OBJ)/vm_test.o $(OBJ)/vm_slow.o
	$(CC) $(OSFLAG) -s "$(OBJ)/vm_test.o" "$(OBJ)/vm_slow.o" \
        -o $@ $(FLAGS) $(LIBS)

$(BIN)/ibniz2c: makeobjdirs cleanbins \
  $(OBJ)/ibniz2c.o $(OBJ)/compiler.o $(OBJ)/gen_c.o
	$(CC) -DIBNIZ2C $(OSFLAG) -s \
        "$(OBJ)/ibniz2c.o" "$(OBJ)/compiler.o" "$(OBJ)/gen_c.o" \
        $@ $(FLAGS) $(LIBS)

# clean etc

clean: cleanbins
	@rm -f "$(OBJ)/*"

package: clean
	cp -R "$(SRC)" ibniz-1.1D && bsdtar -czf ibniz-1.1D.tar.gz ibniz-1.1D

winexe: clean
	cp "$(SRC)/*" winbuild && cd winbuild && make -f "$(SRC)/Makefile.win"

# C stuff

$(OBJ)/ui_sdl.o: $(SRC)/ui_sdl.c
	$(CC) $(OSFLAG) -c $< -o $@ $(FLAGS) $(LIBS)

$(OBJ)/vm_slow.o: $(SRC)/vm_slow.c
	$(CC) $(O3FLAG) -c $< -o $@ $(FLAGS) $(LIBS)

$(OBJ)/clipboard.o: $(SRC)/clipboard.c
	$(CC) $(OSFLAG) -c $< -o $@ $(FLAGS) $(LIBS)

$(OBJ)/compiler.o: $(SRC)/compiler.c
	$(CC) $(OSFLAG) -c $< -o $@ $(FLAGS) $(LIBS)

$(SRC)/font.i: $(SRC)/font.pl
	perl $< > $@

$(OBJ)/vm_test.o: $(SRC)/vm_test.c
	$(CC) -c $< -o $@ $(FLAGS) $(LIBS)

# For win32 builds using mingw32 (you'll probably need to modify these)
#CC=i586-mingw32msvc-gcc
#EXE=ibniz.exe
#FLAGS=-L./SDL-1.2.14/lib -I./SDL-1.2.14/include -static -lmingw32 SDL-1.2.14/lib/libSDL.a SDL-1.2.14/lib/libSDLmain.a -mwindows -lwinmm

.PHONY: clean all debug release package winexe

