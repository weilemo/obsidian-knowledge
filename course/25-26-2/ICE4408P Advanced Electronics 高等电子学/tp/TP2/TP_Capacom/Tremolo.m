[y,fs]=wavread("Bangbang_norm.wav");
y=y(:,1)'/max(y(:,1)); %normalisation du signal

Ts=1/fs;
N=length(y);
effet=0;        %Pour activer et désativer le Tremolo
activation=[1e-3 1 ; 5 10 ]; %interval d'activation en seconde
fin_or=5; %Fréquence du trmemolo
m=0.9; %indice de la modulation

if (effet)
	Bin_in=round(fin_or/fs*N);
	fin=Bin_in*fs/N;
	t=0:Ts:(length(y)-1)*Ts;
	x=cos(2*pi*fin*t);



	act=ones(1,N);
	nbact=size(activation);
	for i=1:nbact(1)
	    act(floor(activation(i,1)*fs):floor(activation(i,2)*fs))=x(1:floor(activation(i,2)*fs)-floor(activation(i,1)*fs)+1);
	end
	ps=y.*(1+m.*act);
	else
		ps=y;
	

end
soundsc([ps/max(ps)],fs);
