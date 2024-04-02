 %通过设置m可以改变汉明码的纠错能力
 %根据弱速率-歧义率理论，码字长度越长，则歧义率越低

-%Description du jeu : Ce jeu a pour but de déterminer si le secret des données peut être obtenu uniquement par des différences de canaux
-%A est l'expéditeur, B est le partenaire de réception et C est l'ennemi qui écoute.
-%Le canal entre A et B est en très bon état, mais le canal entre A et C est bruyant et présente les caractéristiques du canal BSC.
-%En général, la confidentialité des différences de canaux est liée au taux de transmission, à la longueur des mots codés transmis et au bruit du canal, mais ce jeu ne prend en compte que la longueur des mots codés et le bruit.
-%La transmission est effectuée à l'aide de codes de Hamming complets de différentes longueurs, c'est-à-dire que
-%La longueur du code source est k, la longueur codée est n, la longueur du bit de parité est m, alors n=k+m, k=2^m-m-1, n=2^m-1.
-%La capacité de correction d'erreur du code de Hamming peut être modifiée en réglant m.
-%Selon la théorie du taux d'ambiguïté faible, plus la longueur du mot de code est grande, plus le taux d'ambiguïté est faible.
-
-%设置参数   Paramètres de réglage
-m=4; %奇偶校验位数  bit de parité
-n=2^m-1; %汉明编码后码字总长度  Longueur totale des mots de code après le code Hanming
-k=2^m-m-1;  %编码前码字的划分长度，由于原始数据是一长串，要发送需要分成一段一段的分别编码   La longueur de division du mot de code avant l'encodage, puisque les données d'origine sont une longue chaîne, pour les envoyer il faut les diviser en un segment d'encodage séparé.
+%设置参数
+m=4; %奇偶校验位数
+n=2^m-1; %汉明编码后码字总长度
+k=2^m-m-1;  %编码前码字的划分长度，由于原始数据是一长串，要发送需要分成一段一段的分别编码


 %首先读取原始数据,使用图片是为了让歧义码更直观

-%Lisez d'abord les données brutes, en utilisant des images pour rendre le code de désambiguïsation plus intuitif.
-
-%导入图片   Importer des images
-[fn,pn,fi]=uigetfile('*.jpg','选择图片'); %Sélectionner l'image
+%导入图片
+[fn,pn,fi]=uigetfile('*.jpg','选择图片');
 I=imread([pn fn]);
 I=rgb2gray(I(1:2,1:3,:));
 % I=[24,25,26;13,14,15];


-%绘制原始图像   Dessiner l'image originale
+%绘制原始图像
 figure(1);
 subplot(1,3,1);
 imshow(I);
-title('Alice的图片'); %images
+title('Alice的图片');
 [si,sj]=size(I);
 sizek=si*sj;

 I_dec=reshape(I,[1,sizek]);
 I_bin=dec2bin(I_dec,8);
-I_Alice=reshape(I_bin',[1,sizek*8]);%转换为二进制数据串，便于传输   Convertie en chaîne de données binaires pour faciliter la transmission
+I_Alice=reshape(I_bin',[1,sizek*8]);%转换为二进制数据串，便于传输
 I_Alice=my_char2bit(I_Alice);

 spare_zero=sizek*8
@@ -53,14 +42,12 @@ spare_zero=sizek*8

 %开始编码

-%Démarrer l'encodage
-
-I_trans=encode(I_Alice,n,k,"hamming/binary"); %Alice使用汉明编码    Utilisation du code de Hamming
+I_trans=encode(I_Alice,n,k,"hamming/binary"); %Alice使用汉明编码


-%Bob的数据经过信道并接收    des données qui transitent par le canal et qui reçoivent
+%Bob的数据经过信道并接收

-I_rB=channel(I_trans,1);  %改这个可以将A-B换成次级信道  En changeant ce paramètre, les canaux A-B deviennent des canaux secondaires.
+I_rB=channel(I_trans,1);  %改这个可以将A-B换成次级信道


 I_Bob_re=decode(I_rB,n,k,"hamming/binary");
@@ -74,18 +61,15 @@ I_Bob_dec=bin2dec(I_Bob_bin);
 I_Bob=uint8(reshape(I_Bob_dec,[si,sj]));

 %显示接收到的图像
-%Affichage des images reçues
 subplot(1,3,2);
 imshow(I_Bob);
-title("Bob收到的图片")  Photos reçues
+title("Bob收到的图片")

 %%

 %Eve的数据经过信道并接收(其实Eve窃听后并未汉明解码，但为了能直观体现干扰效果所以进行解码）
-%Les données ont traversé le canal et ont été reçues (en fait, Eve ne les a pas décodées après avoir écouté, mais les a décodées afin de visualiser l'effet du brouillage).

 I_rE=channel(I_rB,3); %此处说明：根据PPT第72页的信道模型，Eve窃听到的内容其实是先过了一遍A-B信道，然后才传到Eve耳朵里
-                      %Remarque : selon le modèle de canal de la page 72 du PPT, ce qu'Eve écoute passe en fait par le canal A-B avant d'arriver aux oreilles d'Eve.

 I_Eve_re=decode(I_rE,n,k,"hamming/binary");

@@ -95,10 +79,10 @@ I_Eve_bin=my_bit2char(I_Eve_rec);
 I_Eve_dec=bin2dec(I_Eve_bin);
 I_Eve=uint8(reshape(I_Eve_dec,[si,sj]));

-%显示接收到的图像   Affichage des images reçues
+%显示接收到的图像
 subplot(1,3,3);
 imshow(I_Eve);
-title("Eve的窃听图片"); %Les images d'écoutes téléphoniques
+title("Eve的窃听图片");



@@ -116,19 +100,7 @@ title("Eve的窃听图片"); %Les images d'écoutes téléphoniques

 %上述模型描述符号请参照PPT第68页系统模型

-%Statistiques du TEB, de l'entropie conditionnelle et de l'information mutuelle à la sortie du canal de l'extrémité Eve
-
-%Tout d'abord, d'après l'équation 44 de la page 70~71 du PPT, on peut constater que, puisque le code de Hamming appartient au codage déterministe, l'information mutuelle entre X^n et Z^n dans les conditions d'envoi de M est de 0, l'information mutuelle entre X^n et Z^n est de 0, l'information mutuelle entre X^n et Z^n est de 0, l'information mutuelle est de 0.
-%Avec l'équation 21 de la page 26 du PPT, I(M;Z^n)=I(X^n;Z^n)=H(X^n)+H(Z^n)-H(X^n,Z^n)
-
-%Ensuite, une légère transformation basée sur l'équation 19 de la page 26 du PPT montre que H(M|Z^n)=H(M)-I(M;Z^n)
-
-%L'objectif de ces deux étapes de transformation est que les données d'origine M n'ont pas la même longueur que les données X^n,Z^n après le codage de Hamming et qu'il est impossible de compter directement leur entropie conditionnelle et leur information mutuelle.
-%Par conséquent, elles peuvent être converties pour étudier la relation entre X^n et Z^n.
-
-%Veuillez vous reporter à la page 68 du PPT pour la notation de la description du modèle ci-dessus.
-
-%首先统计Alice编码前的P(0)和P(1)    Tout d'abord, les P(0) et P(1) avant le codage d'Alice ont été comptés
+%首先统计Alice编码前的P(0)和P(1)
 m_p=zeros(1,2);
 for i=1:sizek*8
     if(I_Alice(i)==0)
@@ -139,11 +111,11 @@ for i=1:sizek*8
 end
 m_p=m_p./(sizek*8);

-%计算H(M)   Calcul de H(M)
+%计算H(M)
 H_m=-sum(m_p.*log2(m_p));


-%然后统计A编码后的  Comptez ensuite les codes A
+%然后统计A编码后的
 xn_p=zeros(1,2);

 l_xn=length(I_trans);
@@ -157,14 +129,12 @@ for i=1:l_xn
 end
 xn_p=xn_p./l_xn;

-%计算H(X^n) Calcul de H(X^n)
+%计算H(X^n)
 H_xn=-sum(xn_p.*log2(xn_p));


 %然后统计Eve端信道输出Z^n的

-%La sortie du canal Z^n à l'extrémité Eve est alors comptée pour la
-
 zn_p=zeros(1,2);

 l_zn=length(I_rE);
@@ -178,11 +148,11 @@ for i=1:l_xn
 end
 zn_p=zn_p./l_xn;

-%计算H(Z^n)   Calcul de H(Z^n)
+%计算H(Z^n)
 H_zn=-sum(zn_p.*log2(zn_p));


-%最后计算X^n和Z^n之间的联合熵   Enfin, calculez l'entropie conjointe entre X^n et Z^n
+%最后计算X^n和Z^n之间的联合熵
 xz_p=zeros(2,2);

 l_xz=l_xn;
@@ -205,25 +175,24 @@ end

 xz_p=xz_p./l_xz;

-%计算H(X^n,Z^n)   Calcul de H(X^n,Z^n)
+%计算H(X^n,Z^n)
 help_xz_p=reshape(xz_p,[1,4]);
 H_xn_and_zn=-sum(help_xz_p.*log2(help_xz_p));


 %%
 %通过上述四个量，则可以计算条件熵和互信息
-%Avec les quatre quantités ci-dessus, il est alors possible de calculer l'entropie conditionnelle et l'information mutuelle

 I_m_and_zn=H_xn+H_zn-H_xn_and_zn;

 H_m_by_zn=H_m-I_m_and_zn;


-fprintf("条件熵为:%f\n互信息为:%f\n",H_m_by_zn,I_m_and_zn); %L'entropie conditionnelle est: {à la ligne} L'information mutuelle est
+fprintf("条件熵为:%f\n互信息为:%f\n",H_m_by_zn,I_m_and_zn);


 %%
-%最后计算一下Eve信道输出处的误码率  Enfin, calculer le TEB à la sortie du canal Eve
+%最后计算一下Eve信道输出处的误码率
 err=0;
 for i=1:l_xn
     if(I_rE(i)~=I_trans(i))
@@ -231,9 +200,9 @@ for i=1:l_xn
     end
 end

-err=err/l_xn;  %由于数据量非常大，该值会无限接近于设定的信道错误率P值   En raison de la très grande quantité de données, cette valeur sera infiniment proche du taux d'erreur de canal fixé Valeur P
+err=err/l_xn;  %由于数据量非常大，该值会无限接近于设定的信道错误率P值

-fprintf("Eve信道输出误码率为:%f\n",err); %Le TEB de sortie de la voie est
+fprintf("Eve信道输出误码率为:%f\n",err);