
# coding: utf-8

# In[1]:

import luigi
import time
import os


# In[36]:

sch = luigi.RemoteScheduler(url=os.environ.get('SCHEDULER_HOST'))

# In[39]:

worker = luigi.worker.Worker(scheduler=sch)


# In[44]:

while True:
    worker.run()
    time.sleep(5)

