% sinusoidal generator (Euler explicite)

k=0.05; N=1000;

x=zeros(N); y=zeros(N);
x(1)=1;

for i = 1:N-1,
  x(i+1) = x(i) + k * y(i);
  y(i+1) = y(i) - k * x(i);
end

%-- figures:

figure(1); clf(); title("vecteurs x et y");
t=(1:N); plot(t,[x,y]); legend('x','y');
grid on

figure(2); clf(); title("plan de phase");
plot(x,y,'.'); xlabel('x'); ylabel('y');
axis(axis(),"square")
grid on

