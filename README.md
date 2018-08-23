# Explore2p :microscope:

## Summary ##

This GUI is developed to interactively explore and visualize functional imaging data (e.g. from Two-Photon '2P' microscopy). It conveniently takes the output of a popular preprocessing package, [Suite2p](https://github.com/cortex-lab/Suite2P), as input data. Experimental recordings of the stimulus (and similarly, behavior, in future versions) are imported as well. The data can be curated in the GUI quickly in terms of selecting a subset of cells or time-points. Different analyses can be performed in quick succession on the exact data subset that is visualized. This platform vastly simplifies bookkeeping and visualizations, and is ment to be developed for prototyping any custom analyses that operates on less than the full dataset. 


All data curated in the GUI can also be easily edited in the MATLAB workspace (see demo\demo_workspace_interactive.m) or in script form (see demo\demo_script.m); import back to the GUI for further exploration and visualization. 
    
    

## Quick start ##

After downloading the code package, find the file 
```
demo_load_GUI.m 
```
and open it in MATLAB. 
Running this script should add the correct directories to the MATLAB search path. 
(Alternatively, add the code folder with subfolders manually). 
The demo data (only ~90MB) should download automatically. When the GUI launches with this demo, it should look like this:

![demo1]

Hover your mouse over text labels (e.g. 'Cluster range') to see tool-tips pop up. 

Some useful examples:

- View the data in grayscale heatmaps (Menu\\View\\Lines/Grayscale)
- Select only a subset of cells (e.g. Tabgroup\\Selection\\Cell range, type '1:20' into the text box and press Enter to only show the first 20 cells)
- Select only a subset of time-frames (e.g. for Tabgroup\\Selection\\Block range', type '1')
- View traces averaged across stimulus repetitions (Menu\\Edit\\Trace avg.)
- Show stimulus legends (Menu\\View\\Show stimulus legend)
- Rank the cells based on the number of pixels within the ROI (Tabgroup\\Operations\\Rank cells, choose 'num pixels')
- To cluster based on functional activity, type number of clusters (e.g. 8) into Tabgroup\\Clustering\\k-means. If you are viewing the data in grayscale (instead of lines), cluster assignments are explicitly visualized.
- To show all cells, type '1:end' into Tabgroup\\Selection\\Cell range
- To show all ROI's (including the ones not curated as cells), type '1:end' into Tabgroup\\Selection\\ROI range
- Cell curation, i.e. deciding whether an automatically segemented ROI is a cell or not, should have been done in Suite2p. In case of sparse regrets, you can toggle cell/not cell in this GUI by entering a single cell/ROI ID into Tabgroup\\Selection\\Cell/not cell(!). A warning will appear.


__Feature Highlight: the BACK button__

(Menu\\Edit\\_Back_ and Menu\\Edit\\_Forward_) Clicking this undoes the last (up to 20) steps of data slicing and grouping (but not the visualizations, nor cell-vs-not-cell assignments). 
Sometimes, even bugs can be circumvented by simply reverting to the last step...



### Load your own 2p data ###

Load your local Suite2p output files (in the format of *proc.mat) from the GUI Menu\\File\\LoadData. 



### Related project ###

This GUI is inspired by/adapted from my [first GUI](https://github.com/xiuyechen/FishExplorer), developed for a larval zebrafish project, now in [preprint](https://www.biorxiv.org/content/early/2018/03/27/289413) on biorxiv.



### Contact ###

For questions, contact me at xiuye.chen (at) g m a i l. :shipit:



[demo1]: docs/screenshot_init.png "GUI snapshot upon loading demo data"
