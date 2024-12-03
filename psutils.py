import signal
import psutil
import os
import platform

class PS_Util:
    def __init__(self, cmd, timeout=60):
        self.cmd = cmd
        self.timeout = timeout
    
    def start_process(self):
        self.process = psutil.Popen(self.cmd, shell=True)
    
    def wait_for_status(self):
        try:
            self.process.wait(timeout=self.timeout)
        except psutil.TimeoutExpired:
            print("process id running in popen: ", self.process.pid)
            sig = signal.SIGINT if platform.system() != 'Windows' else signal.CTRL_C_EVENT
            is_recursive = False if platform.system() == 'Windows' else True
            self.kill_proc_tree(self.process.pid, 
                                sig=sig,
                                recursive=is_recursive)
            
        
    def kill_proc_tree(self, pid, sig=signal.SIGTERM, include_parent=False, recursive=True):
        """Kill a process tree (including grandchildren) with signal
        "sig" and return a (gone, still_alive) tuple.
        "on_terminate", if specified, is a callback function which is
        called as soon as a child terminates.
        """
        assert pid != os.getpid(), "won't kill myself"
        parent = psutil.Process(pid)
        children = parent.children(recursive=recursive)
        if include_parent:
            children.append(parent)
        print("children: ", children)
        for p in children:
            try:
                print("killing process: ", p)
                p.send_signal(sig)
            except psutil.TimeoutExpired as e:
                print("Error: ", e)
                pass

    def on_terminate(self, proc):
        print("process {} terminated with exit code {}".format(proc, proc.returncode))

if __name__ == '__main__':
    print("Script id: ", os.getpid())
    cmd = 'pwsh test-script.ps1'
    ps_util = PS_Util(cmd, timeout=5)
    ps_util.start_process()
    ps_util.wait_for_status()
    
    