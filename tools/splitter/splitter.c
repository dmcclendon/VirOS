/*
#
#############################################################################
#
# splitter: a tool to word split a line of text on unquoted whitespace
#
#############################################################################
#
# Copyright 2007 Douglas McClendon <dmc AT filteredperception DOT org>
#
#############################################################################
#
#This file is part of VirOS.
#
#    VirOS is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    VirOS is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with VirOS.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################
*/

//
// standard required libraries/headers for basic socket com
//

// for fprintf
#include <stdio.h>
// for exit...
#include <stdlib.h>
// for strlen
#include <string.h>

//
// constants
//

// none

//
// prototypes
//

// none

//
// main
//
int main(int argc, char *argv[]) {

  if (argc != 2) {
    fprintf(stderr, "\n\nusage: %s \'<string>\'\n\n", argv[0]); 
    exit (1);
  }

  int i=0;

  int inquotes=0;
  int protectnext=0;
  while (i < strlen(argv[1])) {
    if (!inquotes) {
      if (argv[1][i] == '\\') {
	fprintf(stdout,"%c", '\\');
	protectnext=1;
      } else if (argv[1][i] == ' ') {
	fprintf(stdout,"%c", '\n');
      } else if (argv[1][i] == '"') {
	fprintf(stdout,"%c", '"');
	if (protectnext) {
	  protectnext=0;
	} else {
	  inquotes=1;
	}
      } else {
	fprintf(stdout,"%c", argv[1][i]);
      }
    } else {
      if (argv[1][i] == '\\') {
	fprintf(stdout,"%c", '\\');
	protectnext=1;
      } else if (argv[1][i] == '"') {
	fprintf(stdout,"%c", '"');
	if (protectnext) {
	  protectnext=0;
	} else {
	  inquotes=0;
	}
      } else {
	fprintf(stdout,"%c", argv[1][i]);
      }
    }
    i++;
  }

  fprintf(stdout,"%c", '\n');
  
  exit(0);
}

//
// functions
//

// none
