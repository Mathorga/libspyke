CCOMP=gcc
NVCOMP=nvcc

STD_CCOMP_FLAGS=-std=c17 -Wall -pedantic -g
CCOMP_FLAGS=$(STD_CCOMP_FLAGS)
CLINK_FLAGS=-Wall

ifdef CUDA_ARCH
CUDA_ARCH_FLAG=-arch=$(CUDA_ARCH)
else
CUDA_ARCH_FLAG=
endif

NVCOMP_FLAGS=--compiler-options '-fPIC' -G $(CUDA_ARCH_FLAG)
NVLINK_FLAGS=$(CUDA_ARCH_FLAG)

STD_LIBS=-lrt -lm
CUDA_STD_LIBS=-lcudart
LIBS=$(STD_LIBS)

SRC_DIR=./src
BLD_DIR=./bld
BIN_DIR=./bin

SYSTEM_INCLUDE_DIR=/usr/include
SYSTEM_LIB_DIR=/usr/lib

# Adds BLD_DIR to object parameter names.
OBJS=$(patsubst %.o,$(BLD_DIR)/%.o,$^)

MKDIR=mkdir -p
RM=rm -rf

# Installs the library files (headers and compiled) into the default system lookup folders.
all: create lib
	sudo $(MKDIR) $(SYSTEM_INCLUDE_DIR)/imago
	sudo cp $(SRC_DIR)/*.h $(SYSTEM_INCLUDE_DIR)/imago
	sudo cp $(BLD_DIR)/libimago.so $(SYSTEM_LIB_DIR)
	@printf "\nInstallation complete!\n\n"

standard: create stdlib
	sudo $(MKDIR) $(SYSTEM_INCLUDE_DIR)/imago
	sudo cp $(SRC_DIR)/*.h $(SYSTEM_INCLUDE_DIR)/imago
	sudo cp $(BLD_DIR)/libimago.so $(SYSTEM_LIB_DIR)
	@printf "\nInstallation complete!\n\n"

cuda: create cudalib
	sudo $(MKDIR) $(SYSTEM_INCLUDE_DIR)/imago
	sudo cp $(SRC_DIR)/*.h $(SYSTEM_INCLUDE_DIR)/imago
	sudo cp $(BLD_DIR)/libimago.so $(SYSTEM_LIB_DIR)
	@printf "\nInstallation complete!\n\n"

uninstall: clean
	sudo $(RM) $(SYSTEM_INCLUDE_DIR)/imago
	sudo $(RM) $(SYSTEM_LIB_DIR)/libimago.so
	sudo $(RM) $(SYSTEM_LIB_DIR)/libimago.a
	@printf "\nSuccessfully uninstalled.\n\n"



# Unused static lib.
static: imago_std.o utils.o
	ar -cvq $(BLD_DIR)/libimago.a $(OBJS)


# Builds all library files.
stdlib: imago_std.o utils.o
	$(CCOMP) $(CLINK_FLAGS) -shared $(OBJS) -o $(BLD_DIR)/libimago.so

cudalib: imago_cuda.o utils.o
	$(NVCOMP) $(NVLINK_FLAGS) -shared $(OBJS) $(CUDA_STD_LIBS) -o $(BLD_DIR)/libimago.so
#	g++ -Wall -g -shared -Wl,--export-dynamic $(patsubst %.o, $(BLD_DIR)/%.o, $^) $(STD_LIBS) -o $(BLD_DIR)/libimago.so -lcudart

lib: imago_std.o imago_cuda.o utils.o
	$(CCOMP) $(CLINK_FLAGS) -shared $(OBJS) -o $(BLD_DIR)/libimago.so



# Builds object files from source.
%.o: $(SRC_DIR)/%.c
	$(CCOMP) $(CCOMP_FLAGS) -c $^ -o $(BLD_DIR)/$@

%.o: $(SRC_DIR)/%.cu
	$(NVCOMP) $(NVCOMP_FLAGS) -c $^ -o $(BLD_DIR)/$@



# Creates temporary working directories.
create:
	$(MKDIR) $(BLD_DIR)
	$(MKDIR) $(BIN_DIR)

# Removes temporary working directories.
clean:
	$(RM) $(BLD_DIR)
	$(RM) $(BIN_DIR)