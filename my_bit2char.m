function charr = my_bit2char(bitt)
%UNTITLED3 此处提供此函数的摘要
%   此处提供详细说明

 
%UNTITLED3 Un résumé de cette fonction est disponible ici
%   Une description détaillée est disponible ici
  

[ki,kj]=size(bitt);

charr=zeros(ki,kj);

for i=1:ki
    for j=1:kj
        if(bitt(i,j)==1)
            charr(i,j)='1';
        else
            charr(i,j)='0';
        end
    end
end

charr=char(charr);


end