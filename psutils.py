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
            self.kill_proc_tree(self.process.pid, on_terminate=self.on_terminate)
            #raise Exception('Task terminated due to timeout.')
        
    def kill_proc_tree(self, pid, sig=signal.SIGTERM, include_parent=False,
                   timeout=10, on_terminate=None):
        """Kill a process tree (including grandchildren) with signal
        "sig" and return a (gone, still_alive) tuple.
        "on_terminate", if specified, is a callback function which is
        called as soon as a child terminates.
        """
        assert pid != os.getpid(), "won't kill myself"
        parent = psutil.Process(pid)
        children = parent.children(recursive=False)
        if include_parent:
            children.append(parent)
        print("children: ", children)
        for p in children:
            try:
                print("killing process: ", p)
                if platform.system() == 'Windows':
                    p.send_signal(signal.CTRL_C_EVENT)
                else:
                    p.send_signal(signal.SIGINT)
            except psutil.TimeoutExpired as e:
                print("Error: ", e)
                pass

    def on_terminate(self, proc):
        print("process {} terminated with exit code {}".format(proc, proc.returncode))

if __name__ == '__main__':
    print("Script id: ", os.getpid())
    cmd = 'pwsh test-script.ps1'
    #cmd = 'python -m pytest -s'
    # result_path = 'results'
    # logging_name = 'test_one'
    # suite_name = 'test_one'
    # test_suite_dir = 'test/test-one'
    # cmd = f"mkdir {result_path}"
    # cmd += (
    #     f" && python -m pytest {test_suite_dir} -rpP -v  "
    #     f"--log-file {result_path}/{logging_name}.log "
    #     f"--junitxml {result_path}/{logging_name}.xml "
    #     f"-o junit_suite_name={suite_name} "
    #     f"-o junit_family=xunit1 "
    #     f"--capture=tee-sys > {result_path}/{logging_name}.txt"
    #     )
    #print("cmd: ", cmd)
    ps_util = PS_Util(cmd, timeout=5)
    ps_util.start_process()
    ps_util.wait_for_status()
    #print('Task completed.')
    
    