function bitt = my_char2bit(charr)
%UNTITLED2 此处提供此函数的摘要
%   此处提供详细说明


 
%UNTITLED2 Un résumé de cette fonction est fourni ici
%   Une description détaillée est disponible ici
  

k=length(charr);

bitt=zeros(1,k);

for i=1:k
    if(charr(i)=='1')
        bitt(i)=1;
    else
        bitt(i)=0;
    end
end


end