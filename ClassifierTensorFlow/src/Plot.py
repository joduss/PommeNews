import matplotlib.pyplot as plt
import matplotlib.pylab as pl
import numpy as np

def plotLosses(x, yAndLabels, fig=None):
    if fig is None:
        fig = plt.figure()

    plt.clf()
    plt.ion()
    ax = fig.subplots()

    i = 0
    for y in yAndLabels:
        ax.plot(x, y[0], label=y[1])
        i = i+1

    plt.xticks(x)
    fig.autofmt_xdate()

    ax.set_title("Losses")
    ax.legend()

    plt.get_current_fig_manager().show()
    plt.pause(0.05)

    return fig