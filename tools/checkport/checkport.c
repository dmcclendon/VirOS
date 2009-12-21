/*
#
#############################################################################
#
# checkport: a tool to check if a port is available for use
#
#############################################################################
#
# Copyright 2007-2009 Douglas McClendon <dmc AT filteredperception DOT org>
#
#############################################################################
#
# This file is part of VirOS.
#
#    VirOS is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, version 3 of the License.
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

/*
 * usage: checkport <port number>
 *
 * returns: 0 if port is open and passed sanity test
 *          1 if port is not open or did not pass sanity test
 *
 * NOTE: this is a somewhat more original and simple socket/tcp/fork 
 *       reference than my KU-EECS-672 pa1 code. 
 *
*/

// example compile: 
// gcc -Wall -Wstrict-prototypes -g -O2 -o checkport checkport.c 


//
// standard required libraries/headers for basic socket com
//

// for read/write/...
#include <unistd.h>
// for various things, including wait
#include <sys/types.h> 
// for wait
#include <sys/wait.h>
// for fprintf
#include <stdio.h>
// for strtol, exit...
#include <stdlib.h>
// for strtol error checking
#include <errno.h>
#include <limits.h>
// for strlen
#include <string.h>
// for bzero...
#include <strings.h>
// the rest are for for sockets...
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

//
// constants
//
#define TESTMSG "this is a test message -ZyX"

//
// prototypes
//

// sendmessage: sends a test message to the specified port on the localhost
int sendmessage(int portnumber);

// launchclient: launches a client to send a test message (fork wrapper)
pid_t launchclient(int portnumber);


//
// main
//
// checkport launches a server on the specified port, then forks a child
//           process which sends a test message to the server.  If all 
//           goes well, exit success(0), else exit failure(1)
//
int main(int argc, char *argv[]) {

  // for error checking strtol
  char *endptr, *str;
  long val;

  // pid of the client child process
  pid_t childpid;

  // for return value of the final wait(ing for the child process to exit)
  pid_t somechild;

  // file descriptor for the server socket
  int serversocketfd;

  // file descriptor for the test connection socket
  int testsocketfd;

  // port number specified by the user on the commandline
  long portnumber;

  // simple data buffer for use with the socket
  char buffer[256];

  // for standard socket address structure (of the server)
  struct sockaddr_in server_address;

  // for standard socket address structure (of the accepted test connection)
  // (note: data returned by accept is not used by checkport subsequently)
  int client_length;
  struct sockaddr_in client_address;

  // for read/write return values
  int numbytes;

  //
  // parse commandline
  //
  // TODO: add better getopt-ish, with --verbose and --testmessage=
  if (argc < 2) {
    fprintf(stderr,"\n\nusage: checkport <port number>\n\n\n");
    exit(1);
  }

  //
  // get the user specified port number from the command line args
  //

  str = argv[1];
  // error check strtol // code verbatim from man strtol
  errno = 0;    /* To distinguish success/failure after call */
  val = strtol(str, &endptr, 10);

  /* Check for various possible errors */

  if ((errno == ERANGE && (val == LONG_MAX || val == LONG_MIN))
      || (errno != 0 && val == 0)) {
    perror("strtol");
    exit(EXIT_FAILURE);
  }

  if (endptr == str) {
    fprintf(stderr, "No digits were found\n");
    exit(EXIT_FAILURE);
  }

  /* If we got here, strtol() successfully parsed a number */
  portnumber = val;

  // open an internet stream socket for the server
  serversocketfd = socket(AF_INET, SOCK_STREAM, 0);
  if (serversocketfd < 0) {
    perror("checkport: error: main failed to open server socket");
    exit(1);
  }

  // initialize/zero-out the server_address structure
  bzero((char *) &server_address, sizeof(server_address));
  // configure the server_address structure for checkport's purposes
  // INET, vs e.g. UNIX for local non network sockets
  server_address.sin_family = AF_INET;
  // ?
  server_address.sin_addr.s_addr = INADDR_ANY;
  // configure port using correct network(htons) format
  server_address.sin_port = htons(portnumber);

  // try to bind to the socket (this is the main checkport test)
  if (bind(serversocketfd, (struct sockaddr *) &server_address,
	   sizeof(server_address)) < 0) {
    perror("checkport: error: main failed to bind to server socket");
    exit(1);
  }

  // listen for connections
  if (listen(serversocketfd,1) < 0) {
    perror("checkport: error: main failed to listen to server socket");
    exit(1);
  }

  // since binding and listening worked, fork off a process to 
  // send ourselves a test message.
  // NOTE: listen above enables a queue of incoming connections, which
  //       is where the client goes, before accept pulls the requested
  //       connection from the queue.
  childpid = launchclient(portnumber);

  // client_length and client address are required for the accept syscall,
  // but are not actually used subsequently by checkport.  Presumably they
  // would be used if we cared about the origin of the incoming connection.
  // (i.e. if we were getting nmap-ed at this precise time, we would see
  // a 'corrupt' test message.  An improvement, would be to discard 
  // connections not from the localhost.  But despite the verboseness of
  // this code as a personal reference, that is more than I care about now).
  client_length = sizeof(client_address);

  // accept the connection and process it
  testsocketfd = accept(serversocketfd, 
			(struct sockaddr *)&client_address, 
			(socklen_t *)&client_length);
  if (testsocketfd < 0) {
    perror("checkport: error: main failed to accept on server socket");
    exit(1);
  }

  // initialize the data buffer (seems unneeded?)
  bzero(buffer,256);

  //
  // read test message
  //
  numbytes = read(testsocketfd,buffer,255);
  if (numbytes < 0) {
    perror("checkport: error: main failed to read from server socket");
    exit(1);
  }

  // debug/info
  //  fprintf(stderr, "checkport: info: server received test message: %s\n",buffer);

  //
  // write/reflect message
  //
  numbytes = write(testsocketfd,buffer,strlen(buffer));
  if (numbytes < 0) {
    perror("checkport: error: main failed to write to server socket");
    return(1);
  } else {
    // make sure the child process exits
    somechild = wait(NULL);
    if (childpid != somechild) {
      fprintf(stderr, "checkport: error: problem waiting for client child process to terminate\n");
      fprintf(stderr, "checkport: debug: childpid was %d, somechild was %d\n",
	      childpid, somechild);
      return(1);
    } else {
      return(0); 
    }
  }
}

//
// functions
//

//
// sendmessage: sends a test message to the specified port on the localhost
//
int sendmessage(int portnumber) {

  // file descriptor for the socket to use to send the message
  int socketfd;
  
  // for read/write return values
  int numbytes;

  // for standard socket address structure
  struct sockaddr_in server_address;

  // for standard host structure of the target server (localhost)
  struct hostent *server;
  
  // simple data buffer for use with the socket
  char buffer[256];


  
  // open an internet stream socket for the client
  socketfd = socket(AF_INET, SOCK_STREAM, 0);
  if (socketfd < 0) {
    perror("checkport: error: sendmessage failed to open socket\n");
    exit(1);
  }

  // get standard format identification of target host (i.e. localhost)
  server = gethostbyname("localhost");
  if (server == NULL) {
    fprintf(stderr,"checkport: error: sendmessage failed to look up localhost\n");
    exit(0);
  }

  //
  // connect to portnumber on the localhost
  //
  // initialize/zero-out server_address structure
  bzero((char *) &server_address, sizeof(server_address));
  // configure for address family internet 
  // (as opposed to say AF_UNIX for local system com)
  server_address.sin_family = AF_INET;
  // configure the rest of the structure fields
  bcopy((char *)server->h_addr, 
	(char *)&server_address.sin_addr.s_addr,
	server->h_length);
  // configure port using correct network(htons) format
  server_address.sin_port = htons(portnumber);
  // check for errors
  
  // NOTE: I was confused a bit, and had const as part of the cast of
  //       arg 2, but then realized the confusion was because const
  //       wasn't a necessary (or sensical) part of the cast.  Actually
  //       I'm still a bit confused.  The const in the man 2 connect
  //       prototype confuses me...  I.e. the below doesn't generate
  //       warnings, but theoretically the data in server_address is
  //       not const.  (could be modified by another thread?).
  if (connect(socketfd,
	      (struct sockaddr *)&server_address,
	      sizeof(server_address)) < 0) {
    perror("checkport: error: sendmessage failed to connect");
    exit(1);
  }

  //
  // write test message
  //
  // initialize the data buffer (seems unneeded?)
  bzero(buffer,256);
  // create the test message
  snprintf(buffer,255,TESTMSG);
  // write the test message to the socket
  numbytes = write(socketfd,buffer,strlen(buffer));
  // check for errors
  if (numbytes < 0) {
    perror("checkport: error: sendmessage failed to write to the socket");
    exit(1);
  }

  //
  // read reflected message
  //
  // initialize the data buffer (seems unneeded?)
  bzero(buffer,256);
  // read the reflected test message from the socket (hopefully)
  numbytes = read(socketfd,buffer,255);
  // check for errors
  if (numbytes < 0) {
    perror("checkport: error: sendmessage failed to read from the socket");
    exit(1);
  }

  //
  // check return message
  //
  if (strcmp(TESTMSG, buffer)) {
    fprintf(stderr, "checkport: error: sendmessage received incorrect test message: %s\n",buffer);
    exit(1);
  } else {
    // debug/info
    //    fprintf(stderr, "checkport: info: sendmessage child client received reflected message: %s\n",buffer);
    return(0);
  }
}

//
// launchclient: launches a client to send a test message (fork wrapper)
//
pid_t launchclient(int portnumber) {

  pid_t forkretval;

  //
  // fork a child process 
  //

  forkretval = fork();
  if (forkretval < 0) {
    //
    // fork error occured
    //
    perror( "checkport: error: launchclient failed to fork" );
    exit(1);
  } else if (forkretval == 0) {
    //
    // am child condition 
    //

    // send a test message and exit
    exit(sendmessage(portnumber));

  } else { // forkretval > 0 
    //
    // am parent condition 
    //
    
    // just return the process id of the child
    return(forkretval);
  }
}

