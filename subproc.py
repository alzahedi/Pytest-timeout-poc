import subprocess


class SubProc:
    def __init__(self, cmd, task_timeout=60):
        self.cmd = cmd
        self.task_timeout = task_timeout
    
    def start_process(self):
        self.process = subprocess.Popen(
            self.cmd,
            shell=True,
        )
        
    def wait_for_status(self):
        try:
            self.process.communicate(timeout=self.task_timeout)
        except subprocess.TimeoutExpired:
            self.process.terminate()
            raise Exception('Task terminated due to timeout.')


if __name__ == '__main__':
    cmd = 'pwsh scripts/test-script.ps1'
    subproc = SubProc(cmd, task_timeout=5)
    subproc.start_process()
    subproc.wait_for_status()
    print('Task completed.')
    
