
--creiamo il fulladder
entity FullAdder is

Port(a, b, cin : in bit;
    cout, sum : out bit);

end FullAdder;

architecture MyFa of FullAdder is

signal p: bit;

begin

p <= a xor b;
--se a e b sono uguali, p = 0 -> cout = a
cout <= a when p = '0' else cin;
sum <= p xor cin;

end MyFa;
entity r_carry2 is
--  versione senza component
-- prendo in ingresso i vettori A e B composti da 8 bit e un bit di cin
-- in output invece avrò un vettore di 9 elementi(in generale n + 1 elementi)
Port(A, B : in bit_vector(7 downto 0);
     cin: in bit;
     S : out bit_vector(8 downto 0));
     
end r_carry2;

architecture My_second_carry of r_carry2 is
--in questo caso prendiamo i signal p e g
--p corrisponde allo xor tra A e B
--g corrisponde all'and tra A e B 
signal p,g : bit_vector(8 downto 0);
signal c : bit_vector(9 downto 0);

--iniziamo
begin
--ricordiamo di fare le operazioni tra vettori della stessa dimensione
p(8) <= A(7) xor B(7);
g(8) <= A(7) and B(7);
p(7 downto 0) <= A xor B; 
g(7 downto 0) <= A and B; 

c(9 downto 1) <= g or (p and c(8 downto 0));
s <= p xor c(8 downto 0);

end My_second_carry;


entity carry_select is 
    --mi dichiaro le porte che saranno i vettori A, B in 
    --ingresso e poi S in uscita
    -- So ha dimensioni di 9 perchè incorpora anche l'ultimo bit 
    Port(Acs,Bcs : in bit_vector(15 downto 0);
        So : out bit_vector(16 downto 0));

end carry_select;

architecture My_carry_select of carry_select is

--component mux
component mux is 
Port(a, b, sel : in bit;
     s_out : out bit);
end component;

--componente full adder
component FullAdder is
    Port(a, b, cin : in bit;
    cout, sum : out bit);
end component;
    
--componente ripple carry
component ripple_carry is 
    Port (cin : in bit;
           A : in bit_vector(7 downto 0);
           B :in bit_vector(7 downto 0);
           Sum : out bit_vector(7 downto 0);
           cout : out bit);
end component;

--metto i segn

--quelli intermedi
signal Cout0, Cout1, Cout2, Sout, Coverflow : bit ;
--quelli per la somma di 0 e 1
signal Som0, Som1 : bit_vector(7 downto 0);

begin 
--ora dobbiamo mappare

RCA_primo_blocco : ripple_carry port map('0', Acs(7 downto 0), 
Bcs(7 downto 0), So(7 downto 0),Cout0);
RCA0 : ripple_carry port map('0', Acs(15 downto 8), 
Bcs(15 downto 8), Som0,Cout1);
RCA1 : ripple_carry port map('1', Acs(15 downto 8), 
Bcs(15 downto 8), Som1,Cout2);

--gestiamo i mux attraverso il for 

MyFor: for i in 0 to 7 generate
    Mux_iesimo : mux port map(Som0(i), Som1(i),  Cout0, So(8 + i));
end generate MyFor;

--Mux grande
Mux_dec: mux port map(Cout1, Cout2, Cout0, Sout);

--gestico l'overflow con un Full Adder
FA: fullAdder port map (Acs(15), Bcs(15), Sout,Coverflow ,So(16));

end My_carry_select;
