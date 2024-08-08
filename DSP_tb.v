module DSP_tb ();
    // signals / parameters declaration
    parameter A0REG = 0;   // no register
    parameter A1REG = 1;   // registered
    parameter B0REG = 0;   // no register
    parameter B1REG = 1;   // registered
    parameter CREG = 1;   // registered
    parameter DREG = 1;    // registered
    parameter MREG = 1;    // registered
    parameter PREG = 1;    // registered
    parameter CARRYINREG = 1;  // registered
    parameter CARRYOUTREG = 1; // registered
    parameter OPMODEREG = 1;   // registered
    parameter CARRYINSEL = "OPMODE5";   // to select between carryin input or opmode[5] 
    parameter B_INPUT = "DIRECT";       // sel between B or BCIN to be the output on the mux after the final B port.
    parameter RSTTYPE = "SYNC"; 
    integer i=0;

    reg CLK;
    reg [7:0] OPMODE;
    reg CEA , CEB , CEC , CECARRYIN , CED , CEM , CEP , CEOPMODE;          // clock enable signals
    reg RSTA , RSTB , RSTC , RSTCARRYIN , RSTD , RSTM , RSTP , RSTOPMODE;  // reset signals
    reg [17:0] A , B , D;
    reg [47:0] C;
    reg [47:0] PCIN;
    reg CARRYIN;
    reg [17:0] BCIN;
    wire [35:0] M;
    wire [47:0] P , PCOUT;
    wire  CARRYOUT , CARRYOUTF;
    wire [17:0] BCOUT;

    // module instantiation
    DSP #(A0REG,A1REG,B0REG,B1REG,CREG,DREG,MREG,PREG,CARRYINREG,CARRYOUTREG,OPMODEREG,CARRYINSEL,B_INPUT,RSTTYPE) 
    DSP_DUT(CLK,OPMODE,CEA , CEB , CEC , CECARRYIN , CED , CEM , CEP , CEOPMODE,RSTA , RSTB , RSTC , RSTCARRYIN , RSTD , RSTM , RSTP , RSTOPMODE,A , B , D,C,PCIN,CARRYIN,BCIN,M,P , PCOUT,CARRYOUT , CARRYOUTF,BCOUT);

    // CLK Generation
    initial begin
        CLK = 0;
        forever begin
            #2 CLK = ~CLK;
        end
    end

    // test cases
    initial begin
        // initialize design
        RSTA=1;RSTB=1;RSTC=1;RSTCARRYIN=1;RSTD=1;RSTM=1;RSTP=1;RSTOPMODE=1;
        CEA=0;CEB=0;CEC=0;CECARRYIN=0;CED=0;CEM=0;CEP=0;CEOPMODE=0;
        OPMODE='b0;
        A=0;B=0;C=0;D=0;
        PCIN=0;CARRYIN=0;BCIN=0;
        repeat(5)
            @(negedge CLK);

        RSTA=0;RSTB=0;RSTC=0;RSTCARRYIN=0;RSTD=0;RSTM=0;RSTP=0;RSTOPMODE=0;
        CEA=1;CEB=1;CEC=1;CECARRYIN=1;CED=1;CEM=1;CEP=1;CEOPMODE=1;
        
        // test 1
        A=10;
        B=5;
        C=8;
        D=3;
        BCIN=15;
        CARRYIN=1;
        PCIN=60;
        OPMODE[7]=1'b1;
        OPMODE[6]=1'b0;
        OPMODE[5]=1'b0;
        OPMODE[4]=1'b0;
        OPMODE[3:2]=2'b01;
        OPMODE[1:0]=2'b01;
        repeat(5)
            @(negedge CLK);

        // test 2
        A=12;
        B=4;
        C=30;
        D=5;
        BCIN=7;
        CARRYIN=1;
        PCIN=20;
        OPMODE[7]=1'b0;
        OPMODE[6]=1'b1;
        OPMODE[5]=1'b1;
        OPMODE[4]=1'b1;
        OPMODE[3:2]=2'b11;
        OPMODE[1:0]=2'b00;
        repeat(5)
            @(negedge CLK);

        // test 3
        A=7;
        B=9;
        C=14;
        D=12;
        BCIN=6;
        CARRYIN=0;
        PCIN=22;
        OPMODE[7]=1'b1;
        OPMODE[6]=1'b1;
        OPMODE[5]=1'b1;
        OPMODE[4]=1'b1;
        OPMODE[3:2]=2'b11;
        OPMODE[1:0]=2'b01;
        repeat(5)
            @(negedge CLK);

        // test 4
        A=16;
        B=10;
        C=5;
        D=20;
        BCIN=40;
        CARRYIN=1;
        PCIN=36;
        OPMODE[7]=1'b1;
        OPMODE[6]=1'b1;
        OPMODE[5]=1'b1;
        OPMODE[4]=1'b0;
        OPMODE[3:2]=2'b00;
        OPMODE[1:0]=2'b00;
        repeat(5)
            @(negedge CLK);
        

        // test 5
        A=16;
        B=10;
        C=5;
        D=20;
        BCIN=40;
        CARRYIN=1;
        PCIN=36;
        OPMODE[7]=1'b1;
        OPMODE[6]=1'b1;
        OPMODE[5]=1'b1;
        OPMODE[4]=1'b1;
        OPMODE[3:2]=2'b00;
        OPMODE[1:0]=2'b00;
        repeat(5)
            @(negedge CLK);

        // test 6
        A=16;
        B=10;
        C=5;
        D=20;
        BCIN=40;
        CARRYIN=1;
        PCIN=36;
        OPMODE[7]=1'b0;
        OPMODE[6]=1'b0;
        OPMODE[5]=1'b1;
        OPMODE[4]=1'b1;
        OPMODE[3:2]=2'b00;
        OPMODE[1:0]=2'b00;
        repeat(5)
            @(negedge CLK);
            
        // test 7
        A=16;
        B=10;
        C=5;
        D=20;
        BCIN=40;
        CARRYIN=1;
        PCIN=36;
        OPMODE[7]=1'b0;
        OPMODE[6]=1'b0;
        OPMODE[5]=1'b1;
        OPMODE[4]=1'b1;
        OPMODE[3:2]=2'b11;
        OPMODE[1:0]=2'b11;
        repeat(5)
            @(negedge CLK);
        
        // test 8
        A=16;
        B=10;
        C=5;
        D=20;
        BCIN=40;
        CARRYIN=1;
        PCIN=36;
        OPMODE[7]=1'b0;
        OPMODE[6]=1'b0;
        OPMODE[5]=1'b1;
        OPMODE[4]=1'b1;
        OPMODE[3:2]=2'b10;
        OPMODE[1:0]=2'b10;
        repeat(5)
            @(negedge CLK);
        $stop;   
    end
endmodule