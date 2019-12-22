[y, Fs] = audioread('sample.wav');
t = linspace(0, length(y)/Fs, length(y));
% H = [1 -0.95];
df = Fs/length(y);
x = -Fs/2 : df : Fs/2 - df;
x = Fs*x;
H = ifft(exp(-0.001*abs(x)) + 1);
y_pre = filter(H, 1, y);

figure(1000);
plot(abs(fft(H)));

Fc = 100 * 10^6;
% signal_sent = fmmod(y_pre, Fc, 2*Fc, 75*10^3);
[theta_y, mod_time] = modulator(16, 4, 10, y_pre);
signal_sent = exp(j*theta_y);
noisy = awgn(signal_sent, 25);
r = demodulate(noisy);
% H_de = H.^1;
H_de = ifft(1./fft(H));

deemp = filter(H_de, 1, r);

for i = 0:50
    df = fft(deemp);
    df(df == max(df)) = 0;
    deemp = ifft(df);
end

% deemp = lowpass(deemp, 0.25);
deemp = 1*deemp;

audiowrite('rec.wav', r, Fs);
audiowrite('deemp.wav', real(deemp), Fs);

figure(100);
subplot(4, 1, 1);
plot(fftshift(abs(fft(y))));
subplot(4, 1, 2);
plot(fftshift(abs(fft(y_pre))));
subplot(4, 1, 3);
plot(fftshift(abs(fft(r))));
subplot(4, 1, 4);
plot(fftshift(abs(fft(deemp))));

figure(1);
plot(Fs*(-Fs/2:Fs/length(y):Fs/2 - Fs/length(y)), fftshift(abs(fft(y))));
xlabel('Frequency(Hz)'), ylabel('Amplitude'), grid on
title('FFT of the Audio Signal')

figure(2);
plot(Fs*(-Fs/2:Fs/length(deemp):Fs/2 - Fs/length(deemp)), fftshift(abs(fft(deemp))));
xlabel('Frequency'), ylabel('Amplitude'), grid on
title('FFT of the Audio Signal after demodulating')

figure(200);
subplot(4, 1, 1);
plot(y);
subplot(4, 1, 2);
plot(real(y_pre));
subplot(4, 1, 3);
plot(r);
subplot(4, 1, 4);
plot(real(deemp));

figure(3);
plot(t, y);
xlabel('Time(s)'), ylabel('Amplitude'), grid on
title('Audio Signal');

figure(4);
plot(mod_time, real(deemp));
xlabel('Time(s)'), ylabel('Amplitude'), grid on
title('Audio Signal after demodulating');