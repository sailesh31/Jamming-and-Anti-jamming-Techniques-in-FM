s = rng;           %Random number generation seed

%Audio and noise input files
[y, Fsa] = audioread('sample_1.wav');
[cap,Fsa_c] = audioread('sample.wav');


%Upsampling the audio file to Fs frequency 
y = upsample(y,7);

figure()
plot (cap)
title('Jamming Signal')
xlabel('Length of Signal')
ylabel('Amplitude of Signal')
grid on 


%Upsampling the noise to Fs frequency 
cap = upsample(cap,15);
cap_dist = cap(1:length(y)/10);
a=randperm(10,10)+(-10-1);


%dividing the signal into parts to transmit at different frequencies 
y_dist = zeros(length(y)/10,1);
demod_signal_dist = zeros(length(y)/10,1);

for i = 0:9
     send = y(((i)*length(y)/10 + 1) :((i+1)*length(y)/10)) ;
     y_dist( :, i+1 ) = send ;
end


%Transmission and reception of the message signal
for j = 1:10

    Fc = 1*10^5 + 2000*a(j) ;
    Fs = 3*Fc;
    
    Fcn = 1.5*10^5 ;
    Fsn = 2*Fcn;

    freqdev = 800;
    y_dist(:,j) = lowpass(y_dist(:,j),800,Fs);
    cap_dist = lowpass(cap_dist,800,Fs);
    mod_signal = fmmod(y_dist(:,j),Fc,Fs,freqdev,0);
    %For frequency hopping of the jammer replace Fcn by 10^5+2000*b(j)
    mod_signal = mod_signal + fmmod(cap_dist,Fcn,Fsn,freqdev,0);
    
    mod_signal = bandpass(mod_signal,[Fc-400,Fc+400],Fs);
    x1 = fmdemod(mod_signal,Fc,Fs,freqdev,0);
    demod_signal_dist(:,j)= x1;

end


 demod_signal = demod_signal_dist(:);
 
 
%Removing the noise spikes
 for l = 1:10
   demod_signal(length(y)/10*l-50:length(y)/10*l+50) = 0 ; 
end

%Downsampling to audio frequency
demod_signal = downsample(demod_signal,7);
demod_signal = lowpass(demod_signal, 800, Fsa);
sound(demod_signal*10,Fsa)



figure()
grid on


subplot(2, 1, 1)
plot(y)
title('Transmitted Signal')
xlabel('Length of Signal')
ylabel('Amplitude of Signal')
grid on 


subplot(2, 1, 2)
plot(demod_signal)
title('Received Signal')
xlabel('Length of Signal')
ylabel('Amplitude of Signal')
grid on

