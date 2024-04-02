function out_signal = channel(data,select)
%参数说明：
%data为经过信道前的数据串
%select为选择信道类型，1为理想信道，2为较好的BSC信道，3为较差的BSC信道
%其中A-E一直用3信道，A-B可根据题目中的不同要求选择1或2信道
l=length(data);


%设置BSC信道的错误率
P2=0.05;
P3=0.4; 

out_signal=data;

p=0;

switch select
    case 1
        p=0;
    case 2
        p=P2;
    case 3
        p=P3;
    otherwise
        p=0;
end


for i=1:l

    px=rand();
    if(px<p)
        out_signal(i)=1-out_signal(i);
    end

end


end