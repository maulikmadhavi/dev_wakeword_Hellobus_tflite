import random
import scipy.io.wavfile 
import numpy as np
import glob
import os

random.seed(2020)
wordlist=['BusAgent','HelloBus','OkAgent','OkBus']

original_path="/home/maulik/Documents/Database/data_speech_commands_v0.02/new_dataaug3"

for word in wordlist:
    os.mkdir(os.path.join(original_path,word))

for filename1 in glob.glob(os.path.join(original_path+'/'+'_background_noise_','*.wav')):
    print(filename1)
    for word in wordlist:
        x1 = scipy.io.wavfile.read(filename1)[1]
        for k in range(min(1+len(x1)//16000,30)):
            for filename2 in glob.glob(os.path.join(original_path+'/all/'+word,'*.wav')):
                if len(x1)>16000:
                    st = random.randint(0,len(x1)-12800)
                    x2 = x1[st:st+12800]
                    x3 = scipy.io.wavfile.read(filename2)[1]
                    x2f= np.array(x2/(2**15),dtype=np.float16)
                    x3f= np.array(x3/(2**15),dtype=np.float16)
                    E2 = abs(x2f).max()
                    E3 = abs(x3f).max()
                    if E2 >= E3:
                        x3fn = E2*x3f/E3
                        x2fn = x2f
                    else:
                        x2fn = E3*x2f/E2
                        x3fn = x3f

                    x3fn = np.array(x3fn*2**15, dtype=np.int16)
                    x2fn = np.array(x2fn*2**15, dtype=np.int16)
                    x23 = np.concatenate((x2fn,x3fn))
                    f1 = filename1.split('/')[-1][:-4]
                    f2 = filename2.split('/')[-1][:-4]
                    filename = os.path.join(original_path+'/{}/{}_{}_run{}.wav'.format(word,f1,f2,k))
                    scipy.io.wavfile.write(filename,16000,x23)
