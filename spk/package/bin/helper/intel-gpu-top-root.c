#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>

#define PROGRAM "/var/packages/syno-intel-gpu-top/target/bin/intel_gpu_top.real"
static int flag(const char *arg) {
    return !strcmp(arg, "-h") || !strcmp(arg, "-c") || !strcmp(arg, "-J") ||
           !strcmp(arg, "-l") || !strcmp(arg, "-L") || !strcmp(arg, "-p") ||
           !strcmp(arg, "-m");
}
static int valued(const char *arg) {
    return !strcmp(arg, "-s") || !strcmp(arg, "-d") || !strcmp(arg, "-n");
}
int main(int argc, char **argv) {
    for (int i = 1; i < argc; i++) {
        if (flag(argv[i])) continue;
        if (valued(argv[i]) && i + 1 < argc) { i++; continue; }
        fprintf(stderr, "intel_gpu_top: unsupported privileged option: %s\\n", argv[i]);
        return 2;
    }
    if (setgid(0) || setuid(0)) { perror("intel_gpu_top"); return 1; }
    clearenv(); setenv("PATH", "/usr/bin:/bin", 1);
    setenv("LD_LIBRARY_PATH", "/var/packages/syno-intel-gpu-top/target/lib", 1);
    argv[0] = (char *)PROGRAM; execv(PROGRAM, argv); perror("intel_gpu_top"); return 1;
}
