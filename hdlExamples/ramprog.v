module ramprog(input [11:0] adr, input we,
			inout [31:0] data);

reg [31:0]ram[4095:0];
integer i = 0;

//Op Codes
parameter  NOP        = 4'b0000;
parameter  LOAD       = 4'b0001;
parameter  STORE      = 4'b0010;
parameter  BRANCH     = 4'b0011;
parameter  XOR        = 4'b0100;
parameter  ADD        = 4'b0101;
parameter  ROTATE     = 4'b0110;
parameter  SHIFT      = 4'b0111;
parameter  HALT       = 4'b1000;
parameter  COMPLEMENT = 4'b1001;
parameter  DISPLAY    = 4'b1010;

//Condition Codes
parameter ALWAYS   = 4'b0000;
parameter PARITY   = 4'b0001;
parameter EVEN 	   = 4'b0010;
parameter CARRY    = 4'b0011;
parameter NEGATIVE = 4'b0100;
parameter ZERO     = 4'b0101;
parameter NOCARRY  = 4'b0110;
parameter POSITIVE = 4'b0111;

//first 8 regs
parameter reg0 = 12'b000000000_000;
parameter reg1 = 12'b000000000_001;
parameter reg2 = 12'b000000000_010;
parameter reg3 = 12'b000000000_011;
parameter reg4 = 12'b000000000_100;
parameter reg5 = 12'b000000000_101;
parameter reg6 = 12'b000000000_110;
parameter reg7 = 12'b000000000_111;

//first 8 data memory locations
parameter mem0 = 12'b000001_000000; //64
parameter mem1 = 12'b000001_000001;
parameter mem2 = 12'b000001_000010;
parameter mem3 = 12'b000001_000011;
parameter mem4 = 12'b000001_000100;
parameter mem5 = 12'b000001_000101;
parameter mem6 = 12'b000001_000110;
parameter mem7 = 12'b000001_000111;

//first 10 instruction memory locations
parameter is0 = 12'b000000_000000;
parameter is1 = 12'b000000_000001;
parameter is2 = 12'b000000_000010;
parameter is3 = 12'b000000_000011;
parameter is4 = 12'b000000_000100;
parameter is5 = 12'b000000_000101;
parameter is6 = 12'b000000_000110;
parameter is7 = 12'b000000_000111;
parameter is8 = 12'b000000_001000;
parameter is9 = 12'b000000_001001;
parameter is10 = 12'b000000_001010;

//source types
parameter REG = 1'b0;
parameter MEM = 1'b0;
parameter IMM = 1'b1;

//for bits 24 adn 25 when not using a branch op
parameter xx = 2'b00;
//for when destinaation address is not being used during a branch op
parameter addressx = 12'b000000_000000;

//common immediates
parameter imm0  = 12'b000000_000000;
parameter imm1  = 12'b000000_000001;
parameter imm1n = 12'b111111_111111;


assign data = (we) ? 'bz : ram[adr];

initial begin
	
	for(i = 0; i< 4096; i = i +1) begin
		ram[i] = 'd0;
	end
	
	/** Load store test
	ram[is0] = {LOAD,MEM,REG,xx,mem0,reg0};           //load number in memory0 to reg 0
	ram[is1] = {STORE,REG,MEM,xx,reg0,mem1};          //if it is 0 store answer from reg1 in mem1
	**/
	/**#4 ones in location mem0 (ram[64]) mem1 (ram[65])
	ram[is0] = {LOAD,MEM,REG,xx,mem0,reg0};           //load number in memory0 to reg 0
	ram[is1] = {BRANCH,ZERO,is5,addressx};            //if reg0 is 0 then branch to store/end of program
	ram[is2] = {SHIFT,IMM,REG,xx,imm1,reg0};          //shift reg0 to the right by 1
	ram[is3] = {BRANCH,CARRY,is8,addressx};			  //if the shift carried out a 1 then branch to the add
	ram[is4] = {BRANCH,ALWAYS,is1,addressx};		  //else if it didn't shift again
	ram[is5] = {STORE,REG,MEM,xx,reg1,mem1};          //if it is 0 store answer from reg1 in mem1
	ram[is6] = {DISPLAY,1'b0,1'b0,xx,addressx,mem1};  //display the contents of MEM1
	ram[is7] = {HALT,xx,xx,addressx,addressx};        //Halt
	ram[is8] = {ADD,IMM,REG,xx,imm1,reg1};            //add 1 to answer (reg1)
	ram[is9] = {BRANCH,ALWAYS,is1,addressx};          //branch/loop back to check if reg0 is 0
	ram[mem0] = 'b0000_1111_0001_0001_0000_0000_0000_1111; //setting the memory lcoation to be counted
	**/

	
	//Multiplication following the algorithm described here: http://en.wikipedia.org/wiki/Multiplication_algorithm#Peasant_or_binary_multiplication
	ram[mem0] = 'b0000_0000_0000_0000_0000_0000_0001_1111; //setting the memory location for the multiplicand
	ram[mem1] = 'b0000_0000_0000_0000_0000_0000_0000_1111; //setting the memory location for the multiplier	

	ram[is0] = {LOAD,MEM,REG,xx,mem0,reg0};           //load the multiplicand from memory0 to reg 0
	ram[is1] = {LOAD,MEM,REG,xx,mem1,reg1};           //load the multiplier from memory1 to reg 1
	ram[is2] = {ADD,IMM,REG,xx,imm0,reg1};            //add 0 to the multiplier to set the psr for the value in that reg
	ram[is3] = {BRANCH,ZERO,is8,addressx};            //if the multiplier is 0 branch to the end
	ram[is4] = {ADD,REG,REG,xx,reg0,reg2};            //if it isn't then add the multiplicand to reg2
	ram[is5] = {SHIFT,IMM,REG,xx,imm1,reg1};          //shift the multiplier by one to the right
	ram[is6] = {SHIFT,IMM,REG,xx,imm1n,reg0};         //and shift the multiplicand by one to the left
	ram[is7] = {BRANCH,ALWAYS,is2,addressx};          //Branch to check the multiplier
	ram[is8] = {STORE,REG,MEM,xx,reg2,mem2};          //store the result from reg 2 in mem3
	ram[is9] = {DISPLAY,1'b0,1'b0,xx,addressx,mem2};  //display the contents of mem2
	ram[is10] = {HALT,xx,xx,addressx,addressx};       //Halt
	
	/**
	//convert a number to its negative twos compliment version
	ram[mem0] = 'b0000_0000_0000_0000_0000_0000_0000_0110;
	ram[is0] = {LOAD,MEM,REG,xx,mem0,reg0};           //Load the positive number from mem0
	ram[is1] = {COMPLEMENT,xx,xx,reg0,reg0}; 		  //compliment the number
	ram[is2] = {ADD,IMM,REG,xx,imm1,reg0};			  //add 1 to the number to finish the conversion
	ram[is3] = {STORE,REG,MEM,xx,reg0,mem1};		  //store it in mem1
	ram[is4] = {DISPLAY,1'b0,1'b0,xx,addressx,mem1};  //display the contents of mem1
	ram[is5] = {HALT,xx,xx,addressx,addressx};       //Halt
	**/

	
end

always@(adr) begin
	if(we) begin
		ram[adr] = data;
	end
end

endmodule
