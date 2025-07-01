a=[0, 0, 0, 0, 0; 
   0, 0, 1, 0, 0; 
   0, 1, 0, 1, 1; 
   0, 0, 1, 1, 1];

a = logical(a);

[tl, br] = find_contiguous_block(a, 3, 4);

displ("tl: ", tl.row, ",", tl.col);
displ("br: ", br.row, ",", br.col);
