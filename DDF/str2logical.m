function output=str2logical(string)
   if strcmp(upper(string),"TRUE")
     output = true;
   else
     output = false;
   end
end
