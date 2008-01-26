#
# Makefile for the splitter tool
#

####################
# Global Variables #
####################
TOP         = ../..
include $(TOP)/build/makefile.common

################
# Local Macros #
################

CC = gcc
CFLAGS = -Wall -Wstrict-prototypes -g -O2 

# use static linking since splitter and libvopt.sh will
# get copied to target systems
#STATIC = 
STATIC = -static

###########################
# Source and Object Files #
###########################

SRC = splitter.c
OBJ = $(SRC:.c=.o)
LIBS = 

###############
# Build Rules #
###############

all: splitter

splitter: $(OBJ)
	$(CC) -o splitter $(OBJ) $(LIBS) $(STATIC)

clean:
	rm -f $(OBJ) splitter *~

install: splitter
	$(INSTALL_PROGRAM) -D splitter $(PREFIX)/lib/viros/tools/bin/splitter

uninstall:
	rm -f $(PREFIX)/lib/viros/tools/bin/splitter

