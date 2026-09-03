#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdlib.h>

#define PROGRAM "/var/packages/syno-intel-gpu-top/target/bin/intel_gpu_top.real"
#define SHIM "/usr/bin/intel_gpu_top"
#define WRAPPER "/var/packages/syno-intel-gpu-top/target/bin/intel_gpu_top"
static int flag(const char *arg) {
    return !strcmp(arg, "-h") || !strcmp(arg, "-c") || !strcmp(arg, "-J") ||
           !strcmp(arg, "-l") || !strcmp(arg, "-L") || !strcmp(arg, "-p") ||
           !strcmp(arg, "-m");
}
static int valued(const char *arg) {
    return !strcmp(arg, "-s") || !strcmp(arg, "-d") || !strcmp(arg, "-n");
}
static int path_action(const char *action) {
    struct stat st;
    char target[512];
    ssize_t n;
    if (lstat(SHIM, &st) == 0) {
        if (!S_ISLNK(st.st_mode) || (n = readlink(SHIM, target, sizeof(target) - 1)) < 0) return 1;
        target[n] = '\0';
        if (strcmp(target, WRAPPER)) return 1;
    } else if (errno != ENOENT) return 1;
    if (!strcmp(action, "--remove-path")) return lstat(SHIM, &st) ? 0 : unlink(SHIM);
    return lstat(SHIM, &st) ? symlink(WRAPPER, SHIM) : 0;
}
int main(int argc, char **argv) {
    if (setgid(0) || setuid(0)) { perror("intel_gpu_top"); return 1; }
    if (argc == 2 && (!strcmp(argv[1], "--install-path") || !strcmp(argv[1], "--remove-path")))
        return path_action(argv[1]);
    for (int i = 1; i < argc; i++) {
        if (flag(argv[i])) continue;
        if (valued(argv[i]) && i + 1 < argc) { i++; continue; }
        fprintf(stderr, "intel_gpu_top: unsupported privileged option: %s\\n", argv[i]);
        return 2;
    }
    clearenv(); setenv("PATH", "/usr/bin:/bin", 1);
    setenv("LD_LIBRARY_PATH", "/var/packages/syno-intel-gpu-top/target/lib", 1);
    argv[0] = (char *)PROGRAM; execv(PROGRAM, argv); perror("intel_gpu_top"); return 1;
}
