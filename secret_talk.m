%游戏说明：本游戏旨在研究只靠信道差异是否能实现对数据的保密
%A为发信人，B为收信伙伴，C为窃听敌人
%A和B之间的信道状况非常好，但A和C之间的信道存在较大噪声，且呈现BSC信道特征
%一般来说信道差异的保密性和传输速率，传输的码字长度以及信道的噪声都有关联，但本游戏只考虑码字长度和噪声
%传输采用不同长度的完备汉明码，即：
%源码长度为k,编码后长度为n,奇偶校验位长度为m，则n=k+m,k=2^m-m-1,n=2^m-1
%通过设置m可以改变汉明码的纠错能力
%根据弱速率-歧义率理论，码字长度越长，则歧义率越低

%设置参数
m=4; %奇偶校验位数
n=2^m-1; %汉明编码后码字总长度
k=2^m-m-1;  %编码前码字的划分长度，由于原始数据是一长串，要发送需要分成一段一段的分别编码


%首先读取原始数据,输入想传输的话


I_origin=input('Say something here(enclosed in quotation marks):');  %输入的内容要用单引号框起来，比如'Hello World'

sizek=length(I_origin);

I_dec=abs(I_origin);

I_bin=dec2bin(I_dec,8);
I_Alice=reshape(I_bin',[1,sizek*8]);%转换为二进制数据串，便于传输
I_Alice=my_char2bit(I_Alice);

spare_zero=k-mod(sizek*8,k);  %由于汉明编码时会自动补零以使得数据总量是k的整数倍，则解码后需要将这些0去掉


%% 

%开始编码

I_trans=encode(I_Alice,n,k,"hamming/binary"); %Alice使用汉明编码


%Bob的数据经过信道并接收

I_rB=channel(I_trans,1);  %改这个可以将A-B换成次级信道


I_Bob_re=decode(I_rB,n,k,"hamming/binary");
I_Bob_re(end-spare_zero+1:end)=[]; %去掉补零


I_Bob_rec=reshape(I_Bob_re,[8,sizek])';
I_Bob_bin=my_bit2char(I_Bob_rec);

I_Bob_dec=bin2dec(I_Bob_bin);
I_Bob=char(I_Bob_dec);

%输出Bob接收到的话
fprintf('Bob received:\n');
fprintf(I_Bob);
fprintf('\n');

%% 

%Eve的数据经过信道并接收(其实Eve窃听后并未汉明解码，但为了能直观体现干扰效果所以进行解码）

I_rE=channel(I_rB,3); %此处说明：根据PPT第72页的信道模型，Eve窃听到的内容其实是先过了一遍A-B信道，然后才传到Eve耳朵里

I_Eve_re=decode(I_rE,n,k,"hamming/binary");
I_Eve_re(end-spare_zero+1:end)=[];%去掉补零

I_Eve_rec=reshape(I_Eve_re,[8,sizek])';
I_Eve_bin=my_bit2char(I_Eve_rec);

I_Eve_dec=bin2dec(I_Eve_bin);
I_Eve=char(I_Eve_dec);

%输出Eve窃听到的话
fprintf('Eve received:\n');
fprintf(I_Eve);
fprintf('\n');


%% 

%统计Eve端信道输出处的误码率，条件熵和互信息

%首先根据PPT70~71页公式44可知，由于汉明码属于确定性编码，则发送为M的条件下X^n和Z^n之间的互信息为0，
%再加上PPT第26页公式21，则I(M;Z^n)=I(X^n;Z^n)=H(X^n)+H(Z^n)-H(X^n,Z^n)

%然后根据PPT第26页的公式19稍微变换一下可知，H(M|Z^n)=H(M)-I(M;Z^n)

%这两步变换目的是因为原始数据M与汉明编码后数据X^n,Z^n长度不一样，无法直接统计其条件熵和互信息，
%故转换为研究X^n与Z^n之间的关系即可统计

%上述模型描述符号请参照PPT第68页系统模型

%首先统计Alice编码前的P(0)和P(1)
m_p=zeros(1,2);
for i=1:sizek*8
    if(I_Alice(i)==0)
        m_p(1)=m_p(1)+1;
    else
        m_p(2)=m_p(2)+1;
    end
end
m_p=m_p./(sizek*8);

%计算H(M)
H_m=-sum(m_p.*log2(m_p));


%然后统计A编码后的
xn_p=zeros(1,2);

l_xn=length(I_trans);

for i=1:l_xn
    if(I_trans(i)==0)
        xn_p(1)=xn_p(1)+1;
    else
        xn_p(2)=xn_p(2)+1;
    end
end
xn_p=xn_p./l_xn;

%计算H(X^n)
H_xn=-sum(xn_p.*log2(xn_p));


%然后统计Eve端信道输出Z^n的

zn_p=zeros(1,2);

l_zn=length(I_rE);

for i=1:l_xn
    if(I_rE(i)==0)
        zn_p(1)=zn_p(1)+1;
    else
        zn_p(2)=zn_p(2)+1;
    end
end
zn_p=zn_p./l_xn;

%计算H(Z^n)
H_zn=-sum(zn_p.*log2(zn_p));


%最后计算X^n和Z^n之间的联合熵
xz_p=zeros(2,2);

l_xz=l_xn;

for i=1:l_xz
    if(I_trans(i)==0&&I_rE(i)==0)
        xz_p(1,1)=xz_p(1,1)+1;
    else
        if(I_trans(i)==1&&I_rE(i)==0)
            xz_p(1,2)=xz_p(1,2)+1;
        else
            if(I_trans(i)==0&&I_rE(i)==1)
                xz_p(2,1)=xz_p(2,1)+1;
            else
                xz_p(2,2)=xz_p(2,2)+1;
            end
        end
    end
end

xz_p=xz_p./l_xz;

%计算H(X^n,Z^n)
help_xz_p=reshape(xz_p,[1,4]);
H_xn_and_zn=-sum(help_xz_p.*log2(help_xz_p));


%% 
%通过上述四个量，则可以计算条件熵和互信息

I_m_and_zn=H_xn+H_zn-H_xn_and_zn;

H_m_by_zn=H_m-I_m_and_zn;


fprintf("条件熵为:%f\n互信息为:%f\n",H_m_by_zn,I_m_and_zn);


%% 
%最后计算一下Eve信道输出处的误码率
err=0;
for i=1:l_xn
    if(I_rE(i)~=I_trans(i))
        err=err+1;
    end
end

err=err/l_xn;  %由于数据量非常大，该值会无限接近于设定的信道错误率P值

fprintf("Eve信道输出误码率为:%f\n",err);



