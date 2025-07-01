mt = MTable();

mt.row(["", "Chan. 1", "Ch2", "Vdd", "Date"]);
mt.row(["T1", "5", "3", "12", "12-6-2021"]);
mt.row(["T2", "6", "3.5", "12", "12-6-2021"]);
mt.row(["T3", "7", "200.8", "11", "12-6-2021"]);
mt.title("Demo Data");

displ(mt.str());

mt.alignac('r');
mt.alignt('c');
mt.alignah('r');

displ(newline, mt.str());