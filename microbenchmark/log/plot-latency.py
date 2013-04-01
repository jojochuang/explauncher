#!/usr/bin/python2.7

# a bar plot with errorbars
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib import cm
from optparse import OptionParser

from collections import defaultdict
class Tree(defaultdict):
    def __init__(self, value=None):
        super(Tree, self).__init__(Tree)
        self.value = value

def autolabel(ax, rects):
    # attach some text labels
    for rect in rects:
        height = rect.get_height()
        ax.text(rect.get_x()+rect.get_width()/2., 1.05*height, '%d'%int(height),
            ha='center', va='bottom')

def print_tree(data):
    for k1 in data.keys():
        for k2 in data[k1].keys():
            print( "%s => %s" % (k2, data[k1][k2].value))


def parse(inputfile, group_by, index_by, cols):
    # Group by group_by's column
    data = Tree()
    with open(inputfile, "r") as f:
        for line in f:
            tokens = line.strip().split(" ")
            row = []
            for c in cols:
                row.append(float(tokens[c-1]))
            data[ tokens[group_by-1] ][ tokens[index_by-1] ].value = row

    #print_tree(data)
    return data


def main(options):
    """
    Main module of configure-microbenchmark.
    """

    # By different nprime values
    data = parse(options.inputfile, group_by=3, index_by=1, cols=[4,5])

    ngroups = len(data.keys())
    nrows = len(data[ data.keys()[0] ].keys() )


    #N = 5
    #menMeans = (20, 35, 30, 35, 27)
    #menStd =   (2, 3, 4, 1, 2)

    ind = np.arange(nrows)  # the x locations for the groups
    width = 0.35       # the width of the bars

    fig = plt.figure()
    ax = fig.add_subplot(111)

    rects_legend = []
    rects = [] 

    gid = 0
    xlabel = []
    glabel = []

    nnodes = 10

    for k1 in sorted(data.keys(), key=lambda item: int(item)):
        #print("processing key = %s" % k1)
        means = []
        errors = []
        #glabel.append("P=%s" % (k1))
        glabel.append("Latency")

        # Reconstruct means and errors
        for k2 in sorted(data[k1].keys(), key=lambda item: int(item)):
            if len(glabel) == 1:
                xlabel.append("%s MB" % (float(k2)/1000000))
            means.append(data[k1][k2].value[0])
            errors.append(data[k1][k2].value[1])

        # If it's not enough, add 0s.
        for k in range( len(means), nrows ):
            means.append(0)
            errors.append(0)

        rect = ax.bar(ind+gid*width, means, width, yerr=errors, color=cm.jet(1.*gid/ngroups))
        rects.append(rect)
        rects_legend.append(rect[0])

        gid += 1


    #rects1 = ax.bar(ind, menMeans, width, color='r', yerr=menStd)

    #womenMeans = (25, 32, 34, 20, 25)
    #womenStd =   (3, 5, 2, 3, 3)
    #rects2 = ax.bar(ind+width, womenMeans, width, color='y', yerr=womenStd)

    # add some
    ax.set_ylabel('Latency (ms)')
    #ax.set_title('Migration latency by different size of contexts')

    #print(xlabel)
    #print(glabel)

    ax.set_xticks(ind+width)
    #ax.set_xticklabels( ('G1', 'G2', 'G3', 'G4', 'G5') )
    ax.set_xticklabels( xlabel )

    #ax.legend( (rects1[0], rects2[0]), ('Men', 'Women') )
    #ax.legend( rects_legend, glabel )


    #for r in rects:
        #autolabel(r)
    #autolabel(ax, rects[0])
    #autolabel(ax, rects[1])
    #autolabel(rects2)k/rects


    plt.savefig(options.outputfile)


###############################################################################
# Main - Parse command line options and invoke main()
if __name__ == "__main__":
    parser = OptionParser(description="Plotting by group.")

    parser.add_option("-i", "--input", dest="inputfile", action="store", type="string",
    help="Input .dat file.")
    parser.add_option("-o", "--output", dest="outputfile", action="store", type="string",
    help="Output .pdf file.")


    (options, args) = parser.parse_args()

    # Check missing arguments

    if not options.inputfile:
        parser.error("Missing --input")
    if not options.outputfile:
        parser.error("Missing --output")

    main(options)
