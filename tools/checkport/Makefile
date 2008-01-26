#
# Makefile for the checkport tool
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

###########################
# Source and Object Files #
###########################

SRC = checkport.c
OBJ = $(SRC:.c=.o)
LIBS = 

###############
# Build Rules #
###############

all: checkport

checkport: $(OBJ)
	$(CC) -o checkport $(OBJ) $(LIBS)

clean:
	rm -f $(OBJ) checkport *~

install: checkport
	$(INSTALL_PROGRAM) -D checkport $(PREFIX)/lib/viros/tools/bin/checkport

uninstall:
	rm -f $(PREFIX)/lib/viros/tools/bin/checkport

