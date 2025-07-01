function sb = getsizebytes(x) 
   
props = properties(x); 
   totSize = 0; 
   
   for ii=1:length(props) 
      currentProperty = getfield(x, char(props(ii))); 
      s = whos('currentProperty'); 
      totSize = totSize + s.bytes; 
   end
  
   sb = totSize;
end