import os
import re
import subprocess
# os.system("cat sourc/0xe48a3d7d0bc88d552f730b62c006bc925eadb9ee_CrossChainCanonicalFXS.sol")

for i in os.listdir('source'):
    with open('./source/result.txt','a+') as f:
        # out_bytes = subprocess.check_output(["myth analyze ./source/{0}".format(i)])
        out_bytes = subprocess.check_output(['pwd'])

        f.write(out_bytes.decode('utf-8'))

        
    # print('myth analyze ./source/{0}'.format(i))
    # os.system('myth analyze ./source/{0}'.format(i))