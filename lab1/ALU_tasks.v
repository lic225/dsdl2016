task add16;
  input [15:0] X;
  input [15:0] Y;
  output [15:0] Sum;
  reg [15:0] Sum;
  reg Cin;
  reg Cout;
  integer i;
  
  begin
    Cin = 0;
    for(i = 0; i < 16; i=i+1) begin
      Sum[i] = X[i] ^ Y[i] ^ Cin;
      Cout = (X[i] & Y[i]) | (Y[i] & Cin) | (X[i] & Cin);
      Cin = Cout;
    end
  end
endtask

task sub16;
  input [15:0] A;
  input [15:0] B;
  output [15:0] Dif;
  reg [15:0] Dif;
  reg [15:0] nB;

  begin
    add16(~B, 16'd1, nB);
    add16(A, nB, Dif);
  end
endtask

task neg16;
  input [15:0] A;
  output [15:0] nA;
  reg [15:0] nA;

  begin
    add16(~A, 16'd1, nA);
  end
endtask

task abs16;
  input [15:0] A;
  output [15:0] absA;
  reg[15:0] absA;

  begin
    absA = A;
    if(A[15]) begin
      neg16(A, absA);
    end
  end
endtask

task mul16; // |A| and |B| must <= 2^6
  input [15:0] A;
  input [15:0] B;
  output [15:0] X;
  reg [15:0] X;

  reg [15:0] NewX;

  reg [15:0] absA;
  reg [15:0] absB;
  integer i;
  
  begin
    X = 0;

    abs16(A, absA);
    abs16(B, absB);

    for(i = 0; i < 8; i = i + 1) begin
      if(absA[i]) begin
        add16(X, absB << i, NewX);
        X = NewX;
      end
    end

    if(A[15] ^ B[15]) begin
      add16(~X, 16'd1, NewX);
      X = NewX;
    end
  end
endtask

task div16;
  
  input [15:0] A , B;
  output [15:0] C , rem;

  reg [15:0] rem , C , nC;
  reg isleq;

  integer i;

  begin
    C = 16'd0;
    rem = A;

    for( i = 7 ; i >= 0 ; i = i-1 ) begin
      leq( B << i , rem , isleq );
      if( isleq == 1 ) begin
        sub16( rem , B << i , rem );
        add16( C , 16'd1 << i , nC );
        C = nC;
      end
    end

  end
endtask

task leq; // return a bool indicating A <= B
  input [15:0] A;
  input [15:0] B;
  output leq_bool;

  reg leq_bool;
  reg eq_bool;
  reg [15:0] absA;
  reg [15:0] absB;
  integer i;
  
  begin
    abs16(A, absA);
    abs16(B, absB);

    eq_bool = 1;
    leq_bool = 1;

    for(i = 15; i >= 0 & eq_bool; i = i - 1) begin
      if(absA[i] ^ absB[i]) begin
        eq_bool = 0;
      end
      if(absA[i] > absB[i]) begin
        leq_bool = 0;
      end
    end

    if(A[15] & ~B[15]) begin
      leq_bool = 1;
    end
    if(~A[15] & B[15]) begin
      leq_bool = 0;
    end
    if(A[15] & B[15]) begin
      leq_bool = (~leq_bool) | eq_bool;
    end
  end
endtask

task from6to16;
  input [5:0] sA;
  output [15:0] lA;

  begin
    if(sA[5] == 0) begin
      lA = 0;
      lA[5:0] = sA;
    end
    else begin
      lA = ~0;
      lA[5:0] = sA;
    end
  end
endtask

task from16to12;
  input [15:0] x;
  output [11:0] y;
  output overflow;

  reg leq1 , leq2;

  begin
    leq( x , 16'h0fff , leq1 );
    leq( -16'h0100 , x , leq2 );

    if( leq1 & leq2 ) begin
      y = x[11:0];
      overflow = 0;
    end else begin
      y = 0;
      overflow = 1;
    end
  end

endtask

// If lA is too large, overflow will indicate 1, and sA is set to 0
task from16to6;
  input [15:0] lA;
  output [5:0] sA;
  output overflow;

  reg leq1;
  reg leq2;

  begin
    leq(lA, 16'd31, leq1);
    leq(lA, -16'd33, leq2);
    
    if(leq1 & ~leq2) begin
      overflow = 0;
      sA = lA[5:0];
    end
    else begin
      overflow = 1;
      sA = 0;
    end
  end
endtask

task draw6;
  input [5:0] ip;
  output [20:0] segs;

  reg [5:0] ip;
  reg [20:0] segs;
  reg [6:0] tseg;

  integer i , tmp , x;

  parameter SEG = 7;

  begin
    x = $signed(ip);
    if( x < 0 ) begin
      segs[2*SEG+:SEG] = ~7'b1000000;
      x = -x;
    end else begin
      segs[2*SEG+:SEG] = ~7'b0000000;
    end
    for( i = 0 ; i < 2 ; i = i + 1 ) begin
      tmp = x%10;
      x = x/10;
      case( tmp )
        0:       tseg = ~7'h3F; // 0
        1:       tseg = ~7'h06; // 1
        2:       tseg = ~7'h5B; // 2
        3:       tseg = ~7'h4F; // 3
        4:       tseg = ~7'h66; // 4
        5:       tseg = ~7'h6D; // 5
        6:       tseg = ~7'h7D; // 6
        7:       tseg = ~7'h07; // 7
        8:       tseg = ~7'h7F; // 8
        9:       tseg = ~7'h67; // 9
        default: tseg = ~7'h00; // x
      endcase
      segs[i*SEG +: SEG] = tseg;
    end
  end

endtask

task draw12;
  input [11:0] ip;
  output [39:0] segs;

  reg [11:0] ip;
  reg [34:0] segs;
  reg [6:0] tseg;

  integer i , x , tmp;

  parameter SEG  = 7;

  begin
    x = $signed( ip );
    if( x < 0 ) begin
      segs[4*SEG +: SEG] = ~7'b1000000;
      x = -x;
    end else begin
      segs[4*SEG +: SEG] = ~7'b0000000;
    end
    for( i = 0 ; i < 4 ; i = i+1 ) begin
      tmp = x%10;
      x = x/10;
      case( tmp )
        0: tseg = ~7'h3F; // 0
        1: tseg = ~7'h06; // 1
        2: tseg = ~7'h5B; // 2
        3: tseg = ~7'h4F; // 3
        4: tseg = ~7'h66; // 4
        5: tseg = ~7'h6D; // 5
        6: tseg = ~7'h7D; // 6
        7: tseg = ~7'h07; // 7
        8: tseg = ~7'h7F; // 8
        9: tseg = ~7'h67; // 9
        default:  tseg = ~7'h00; // x
      endcase
      segs[i*SEG +: SEG] = tseg;
    end
  end

endtask