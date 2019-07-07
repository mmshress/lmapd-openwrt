#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <json.h>
#include <uci.h>

int has_ip6(){ //returns 1 if IPv6 is supported, POSIX standard
  if(access("/proc/net/inet_if6", F_OK) != -1){
    return 1;
  }
  return 0;
}

int has_ping(){
  if(access("/bin/ping", F_OK) != -1){
    return 1;
  }
  return 0;
}

int has_mtr(){
  if(access("/usr/bin/mtr", F_OK) != -1){
    return 1;
  }
  return 0;
}

int uci_exists(){//checks if the lmapd UCI file exists
  if(access("/etc/config/lmapd", F_OK) != -1){
    return 1;
  }
  return 0;
}



int main(int argc, char** argv){
  int c;
  int ip6_flag = 0;
  char* host_name = "google.com"; //default hostname to query
  while(c = getopt(argc, argv, "6n:")){
    switch(c){
      case '6':
        if(!has_ip6()){
          printf("IPv6 not supported by this device \n");
          exit(1);
        }
        ip6_flag = 1;
        break;
      case 'n':
        host_name = optarg;
        break;
      default:
        exit();
        break;
    }
  }

  struct uci_ptr ptr;
  struct uci_context *context = uci_alloc_context();

  if(!context) return -1;

  if((uci_lookup_ptr(c, &ptr, path, true) != UCI_OK) ||
    (ptr.o == NULL)

}
