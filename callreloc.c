
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <unistd.h>
#include <fcntl.h>
#include <dlfcn.h>

#include <sys/stat.h>
#include <sys/types.h>
#include <sys/mman.h>

#include <errno.h>

#define PAGESIZE 4096

typedef unsigned int uint;

struct exports_entry
{
  ulong exp_name;
  ulong type;
  ulong func_off;
};

struct exports_table
{
  int                  len;
  struct exports_entry ee[];
};

// reflect the basic structure of a plugin
struct plugin
{
  int                  magic;		// "dynp"
  int                  version;
  ulong                name_off;	// this can't be converted to full pointer
  struct exports_table et;
};

// just a simple structure that contains all loaded plugins
struct container
{
  struct plugin* base;
  size_t         size;
  char*          filename;
};


struct container plugins[10];	// for simplicity, just a static array
int ploaded=0;			// count the plugins loaded


struct plugin* p;
void subsi(long a, long b)
{
    printf("HuHu folks.\n--> %lu\n",a+b);
}

  int load_plugin(char* aName)
  {
    int    cnt;
    int    fd;		// file descriptor
    size_t sz;		// filesize of plugin (rounded up to PAGESIZE)

    struct stat    sb;		// stat buffer
    struct plugin* pmap;	// where the plugin is mapped

    // add error checks
    char* plugin = malloc(strlen(aName)+4);
    strcpy(plugin,aName);

    printf("trying to load dynamic plugin %s...\n",plugin);

    if ((fd=open(plugin,O_RDONLY))==-1)	// system call returns -1 on error
    {
      printf("could not open %s...\n",plugin);
      goto error_need_free;
    }

    if ((sz=fstat(fd,&sb))==-1)		// system call returns -1 on error
    {
      printf("could not stat %s (fd %d)...\n",plugin,fd);
      goto error_need_close;
    }

    sz=sb.st_size;
    sz+=(PAGESIZE-(sz & (PAGESIZE - 1)));		// align to page size

    if (!(pmap=mmap(NULL,sz,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE,fd,0)))
    {
      printf("could not map %s into memory...\n",plugin);
      goto error_need_close;
    }

    // the plugin is now loaded at pmap
    // it starts with 4 byte magic number (which we check first),

    if (pmap->magic!=0x706e7964)
    {
      printf("%s is not a valid plugin...\n",plugin);
      goto error_need_unmap;
    }

    printf("plugin loaded at %p\n",pmap);
    plugins[ploaded].base=pmap;
    plugins[ploaded].size=sz;
    plugins[ploaded].filename=plugin;

    printf("exports table at %p, length %d\n",&pmap->et,pmap->et.len);

    for (cnt=0;cnt<pmap->et.len;cnt++)
    {
      void* r = NULL;
//      if (cnt == 0) {
//	r = subsi;
//	pmap->et.ee[cnt].func_off = r;
//      } else
      if (pmap->et.ee[cnt].func_off)
        r=(char*)pmap + pmap->et.ee[cnt].func_off;
      printf("  %d: function %s at offset 0x%x, relocated to %p\n",
              cnt+1,
              (char*)pmap + pmap->et.ee[cnt].exp_name,
                            pmap->et.ee[cnt].func_off,
              r
            );
    }

    // now we can't relocate the plugin's name on the fly, since it
    // is only 32 bits, but the pointer would take 64 bits
    printf("plugin name at offset 0x%x\n",pmap->name_off);
    //pmap->name=(char*)pmap + pmap->name_off;
    //printf("plugin name at address %p\n",pmap->name);
    printf("%s\n",(char*)pmap + pmap->name_off);

    ploaded++;

    close(fd);
    return 0;

    error_need_unmap: munmap(pmap,sz);
    error_need_close: close(fd);
    error_need_free:  free(plugin);
    return -1;
  }

  void cleanup_plugins()
  {
    int cnt;
    for (cnt=ploaded-1; cnt>=0; cnt--)
    {
      printf("unloading %s\n",(char*)plugins[cnt].base+plugins[cnt].base->name_off);
      free(plugins[cnt].filename);
      plugins[cnt].filename=NULL;
      munmap(plugins[cnt].base,plugins[cnt].size);
      plugins[cnt].base=NULL;
    };
    ploaded=0;
  }

  // query plugin function by plugin number
  // (index in global plugins[])
  void* query_function_an(char* aName, int aPlugin)
  {
    struct plugin* p=plugins[aPlugin].base;
    int cnt;

    for (cnt=0; cnt<p->et.len; cnt++)
    {
      if (strcmp((char*)p + p->et.ee[cnt].exp_name,aName)==0)
      {
        if (!(p->et.ee[cnt].func_off))
          break;
        return (char*)p + p->et.ee[cnt].func_off;
      }
    }
    return NULL;
  }

  // query pluginfunction by plugin name and version
  // meaning that the plugin must _at least_ be that version
  void* query_function_aan(char* aName, char* aPlugin, int aVersion)
  {
//    struct plugin* p;
    int cnt_p;
    int cnt_f;

    for (cnt_p=0; cnt_p<ploaded; cnt_p++)
    {
      printf("looking up plugin %d for %s\n",cnt_p,aName);
      p=plugins[cnt_p].base;
      if (strcmp((char*)p+p->name_off,aPlugin)==0)
      {
        if (p->version>=aVersion)
        {
          for (cnt_f=0; cnt_f<p->et.len; cnt_f++)
          {
//		if (strcmp(aName,"subsi") == 0)
//		{
//			p->et.ee[cnt_f].func_off = *subsi;
//			return  (char*)p+p->et.ee[cnt_f].func_off;
//		}
//		else if (strcmp(aName,"testung") == 0)
//		{
//			p->et.ee[cnt_f].func_off = *testung;
  //                      return  p->et.ee[cnt_f].func_off;
//		}
//		else

            if (strcmp((char*)p + p->et.ee[cnt_f].exp_name,aName)==0)
            {
              if (!(p->et.ee[cnt_f].func_off))
                break;
              return (char*)p + p->et.ee[cnt_f].func_off;
            }
          }
          printf("       not found\n");
        }
        else
          printf("       wrong version (%x < %x)\n",p->version,aVersion);
      }
    }
    return NULL;
  }

// function pointers
long (*start_app)(void) = NULL;

int main(int argc, char** argv)
{
  void *handle;
  void (*test_func)(void);
  char  *error;

  if (argc==1)
  {
    printf("no plugin specified, exiting...\n");
    return 1;
  }

  int cnt;

  for (cnt=0; cnt<argc-1; cnt++)
    load_plugin(argv[cnt+1]);

  if (ploaded==0)
  {
    printf("could not load any of the specified plugins...\n");
    return 2;
  }

  //add=query_function_aan("add",0);
  if (!(start_app = query_function_aan("start","root",0))) {
    printf("error: can't start executable.\n"
	"start symbol not found!\n");
    return 3;
  }

  if (!(handle = dlopen("/home/bak/src/ui/dbase/lib/libkbase.so", RTLD_LAZY))) {
    fputs(dlerror(), stderr);
    exit(4);
  }

  for (;;)
  {
    if (!(strcmp((char*)p + p->et.ee[0].exp_name,"test_func")))
    {
      test_func = dlsym(handle,"test_func");
      if ((error = dlerror()) != NULL) {
        fputs(error, stderr);
        exit(5);
      }
      p->et.ee[0].func_off = *test_func;
    } break;
  }

  //p->et.ee[0].func_off = *test_func;
  printf("---> %p\n", test_func);

  printf("start function is located at %p\n",start_app);
  start_app();
  cleanup_plugins();

  dlclose(handle);
  return 0;
}
