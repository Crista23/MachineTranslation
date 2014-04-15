import matplotlib.pyplot as plt
from  matplotlib import cm
from matplotlib import ticker as tk
import matplotlib.colors as cl
import numpy as np
from collections import defaultdict

def plot(toPlotX,Xdescription,toPlotY,Ydescription,title):
    # Create an actual plot and save it to plots/<plotn>.png
    # 'toPlotX' and 'toPlotY' are the locations of the points
    # 'title' is the title for this plot

    # Formatting of the plot
    thres = 0.000001
    fig = plt.figure()
    plt.xscale('symlog',linthreshx=thres)
    plt.xlim([0,1])
    plt.yscale('symlog',linthreshy=thres)
    plt.ylim([0,1])
    plt.tick_params(axis='both', which='major', labelsize=15)
    plt.tick_params(axis='both', which='minor', labelsize=15)

    plt.scatter(toPlotX,toPlotY)

    plt.axhline(y=thres,linestyle='dashed', color='black')
    plt.axvline(x=thres,linestyle='dashed', color='black')
    plt.xlabel(Xdescription, fontsize=20)
    plt.ylabel(Ydescription, fontsize=20)
    
    # Make colorbar
    l_f = tk.LogFormatter(labelOnlyBase=False)
    if maxFeat < 30:
       myticks = range(0,maxFeat+1,5)
    else:
       myticks = range(0,maxFeat+1,10)
    bar = plt.colorbar(format=l_f,ticks=myticks)
    bar.ax.tick_params(labelsize=15)

    # Add the title and save to file
    plt.title(title, fontsize=25)
    global plotn
    plt.savefig('plots/'+str(plotn), dpi=300)#, format='PDF')
    print 'Saved plot:', plotn
    plotn+=1
    #plt.show()
    


plt.scatter(toPlotX,toPlotY)