lp = LoadPull;

lp.freq = [1, 2, 1, 2, 1, 2, 1, 2, 1, 2];
lp.props.iPower = [1,1,2,2,3,3,4,4,5,5,];
lp.props.iPower = fliplr(lp.props.iPower);

lp.organize("freq", "props.iPower")

lp.showorg();