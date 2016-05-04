module together;
  wire [15:0] A;
  wire [15:0] B;
  
  reg [15:0] S;
  reg [15:0] M;
  reg [15:0] D;
  reg [15:0] Quo , Rem;

  reg [15:0] nA;
  reg [15:0] nB;

  reg [15:0] absA , absB;
  
  reg [5:0] sA;
  reg [15:0] lA;

  reg [11:0] tA;

  reg leq_bool;
  reg overflow;

  test_bench tb1(A, B);
  
  `include"ALU_tasks.v"
  always @(A, B) begin
    $display("---------------");

    leq(A, B, leq_bool);
    $display("%10d <= %10d is %b", $signed(A), $signed(B), leq_bool);

    add16(A, B, S);
    $display("%10d + %10d = %10d", $signed(A), $signed(B), $signed(S));
    
    sub16(A, B, D);
    $display("%10d - %10d = %10d", $signed(A), $signed(B), $signed(D));

    mul16(A, B, M);
    $display("%10d x %10d = %10d", $signed(A), $signed(B), $signed(M));

    abs16( A , absA );
    abs16( B , absB );

    div16(absA, absB, Quo, Rem);
    $display("%10d / %10d = %10d ... %10d",
     $signed(absA), $signed(absB), $signed(Quo), $signed(Rem)
    );

    neg16(A, nA);
    $display("-%10d = %10d", $signed(A), $signed(nA));

    neg16(B, nB);
    $display("-%10d = %10d", $signed(B), $signed(nB));

    sA = -6'sd32;
    from6to16(sA, lA);
    $display("%10d -> %10d", $signed(sA), $signed(lA));

    lA = 16'sd19;
    from16to6(lA, sA, overflow);
    $display("%10d -> %10d (%b)", $signed(lA), $signed(sA), overflow);

    lA = -16'sd19;
    from16to6(lA, sA, overflow);
    $display("%10d -> %10d (%b)", $signed(lA), $signed(sA), overflow);


    lA = 16'sd19;
    from16to12(lA, tA, overflow);
    $display("%10d -> %10d (%b)", $signed(lA), $signed(tA), overflow);

    lA = -16'sd19;
    from16to12(lA, tA, overflow);
    $display("%10d -> %10d (%b)", $signed(lA), $signed(tA), overflow);
  end
endmodule
