import os
import time



def test_two():
    print("Pytest id: ", os.getpid())
    while True:
       time.sleep(1) 
    
    assert 1 == 1