#include <unistd.h>
#include <sys/types.h>

void kill_ptree_inner(pid_t root, int signum, struct kinfo_proc *kp, int kp_len);
int kill_ptree(pid_t root, int signum);
void killed(int signum);
void bring_process_to_foreground();
void setup_dummy_pipe_on_stdin(int pfd[2]);
