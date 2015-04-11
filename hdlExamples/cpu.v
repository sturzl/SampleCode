module cpu( input clk,
			inout [31:0] data,
			output reg [11:0] adr,
			output reg we);

reg [31:0] towrite;
reg [31:0]regs[15:0];
reg [31:0]ir;
reg [4:0] psr;
reg [5:0] pc;
reg halted;
integer i;

assign data = (we) ? towrite : 'bz;

initial begin
	towrite = 'd0;
	adr = 12'b000000000000;
	we = 0;
	psr = 5'b00000;
	pc =  6'b000000;
	ir = 'd0;
  	halted = 0;
  	for(i = 0; i< 16; i = i +1) begin
  		regs[i] = 'd0;
	end
end

// Data in in ram 12'b111111_100000 - 12'b111111_111111
//instructions in ram 12'b000000000000 - 111111_000000
//pc points to instructions in 000000-111111 and gets the insturctin each cycle
always@(posedge clk) begin
	adr = {6'b000000,pc};
	#2
	ir = data;
	if(~halted) begin
	  case (ir[31:28]) 
	    0 : begin //No Op
	          pc = pc + 1'b1;
	        end
	    1 : begin //Load
	          if(ir[27] == 0) begin //load memory value
	            adr = ir[23:12];
	            #2
	            regs[ir[3:0]] = data;
	          end
	          else begin
	            regs[ir[3:0]] = ir[23:12]; //load immediate 
	          end
	          psr[0] = 0;
	      	  setpsr();
	        end
	    2 : begin //Store
	          if(ir[26] == 0) begin //store reg value
	            towrite = regs[ir[15:12]];
				we = 1;
  				adr = ir[11:0];
				#2
				we = 0;
	          end
	          else begin
	            towrite = ir[23:12];
	            we = 1;
				adr = ir[11:0]; //store immediate
				#2
				we = 0;
	          end
	      	  psr = 0;
	          pc = pc+1;
	        end
	    3 : begin //Branch
	    	  case (ir[27:24]) 
	          0 : begin //Always
	                pc = ir[17:12];
	              end 
	          1 : begin//Parity
	                if(psr[1]) begin
	                  pc = ir[17:12];
	                end
	                else pc = pc +1'b1;
	              end
	          2 : begin//even
	                if(psr[2]) begin
	                  pc = ir[17:12];
	                end
	                else pc = pc +1'b1;
	              end
	          3 : begin//carry
	                if(psr[0]) begin
	                  pc = ir[17:12];
	                end
	                else pc = pc +1'b1;
	              end
	          4 : begin//negative
	                if(psr[3]) begin
	                  pc = ir[17:12];
	                end
	                else pc = pc +1'b1;
	              end
	          5 : begin//zero
	                if(psr[4]) begin
	                  pc = ir[17:12];
	                end
	                else pc = pc +1'b1;
	              end
	          6 : begin//no carry
	                if(~psr[0]) begin
	                  pc = ir[17:12];
	                end
	                else pc = pc +1'b1;
	              end
	          7 : begin//positive
	                if(~psr[3]) begin
	                  pc = ir[17:12];
	                end
	                else pc = pc +1'b1;
	              end
	          default : begin
	            $display("no such condition halting");
	            ir[31:28] = 8;
	          end
	        endcase
	        end
	    4 : begin //XOR
	          psr[0] = 0;
	    	    regs[ir[3:0]] = regs[ir[3:0]]^regs[ir[15:12]];
	          setpsr();
	          end
	    5 : begin //add
	          if(ir[27] == 0) begin
	            {psr[0],regs[ir[3:0]]} = regs[ir[15:12]]+regs[ir[3:0]]; //add reg values
	          end
	          else begin//add immediate in source to destination
	            {psr[0],regs[ir[3:0]]} = regs[ir[3:0]]+ir[15:12];//add immediate in source to destination
	          end
	          setpsr();
	          end
	    6 : begin //Rotate
	         psr[0] = 0;
	         if(ir[27] == 0) begin
	      	   if($signed(regs[ir[15:12]]) > 0) begin//rotate by value in source reg
	           regs[ir[3:0]] = ((regs[ir[3:0]] << regs[ir[15:12]]) | (regs[ir[3:0]] >> (16-regs[ir[15:12]])));
	           end
	           else begin 
	             regs[ir[3:0]] = ((regs[ir[3:0]] >> (-1*$signed(regs[ir[15:12]]))) | (regs[ir[3:0]] << (16-(-1*$signed(regs[ir[15:12]])))));
	           end
	         end
	         else begin//rotate by immediate in source
	           if($signed(regs[ir[15:12]]) > 0) begin//rotate by value in source reg
	           regs[ir[3:0]] = ((regs[ir[3:0]] << ir[15:12]) | (regs[ir[3:0]] >> (16-ir[15:12])));
	           end
	           else begin 
	             regs[ir[3:0]] = ((regs[ir[3:0]] >> (-1*$signed(ir[15:12]))) | (ir[3:0] << (16-(-1*$signed(ir[15:12])))));
	           end//rotate by immediate in source
	         end
	         setpsr();
	        end
	    7 : begin //Shift
	        if(ir[27] == 0) begin
	          if($signed(regs[ir[15:12]]) < 0) begin//shift by value in source reg
	            psr[0] = regs[ir[3:0]][31];
	            regs[ir[3:0]] = regs[ir[3:0]] << (-1*$signed(regs[ir[15:12]]));
	          end
	          else begin
	            psr[0] = regs[ir[3:0]][0];
	            regs[ir[3:0]] = regs[ir[3:0]] >> regs[ir[15:12]];
	          end
	        end
	        else begin //shift by immediate in source
	          if($signed(ir[15:12]) < 0) begin//shift by value in source reg
	            psr[0] = regs[ir[3:0]][31];
	            regs[ir[3:0]] = regs[ir[3:0]] << (-1*$signed(ir[15:12]));
	          end
	          else begin
	            psr[0] = regs[ir[3:0]][0];
	            regs[ir[3:0]] = regs[ir[3:0]] >> ir[15:12];
	          end
	        end
	    	  setpsr();
	        end
	    8 : begin //Halt
	      halted = 1;
	    	$display("Halted"); 
	    end
	    9 : begin //Complement
	        	regs[ir[3:0]] = ~regs[ir[15:12]];
	          psr[0] = 0;
	          setpsr();
	          end
	    10 : begin //display memory or reg value for testing
		    	if(ir[27] == 0) begin //display memory value
		            adr = ir[11:0];
		            #2
		            $display($time,,"result in mem is = %b\n", data);
		        end
		        else if(ir[27] == 1) begin //display reg value
		            $display($time,,"result in reg is = %b\n", regs[ir[3:0]]);
		        end
		        pc = pc+1'b1;
	        end
	    default : begin
	              ir = 8;
	            	$display("Error, no such operation, halting."); 
	              end
	    endcase 
	end
end

task setpsr;
  begin
	  psr[2] = 1;
	  for(i = 0; i<32; i = i+1) begin
	    psr[2] = psr[2] + regs[ir[3:0]][i];
	    end
	  psr[1] = ~psr[2];
	  if(regs[ir[3:0]] == 0) begin
	    psr[3] <= 0;
	    psr[4] <= 1;
	    end
	  else if(regs[ir[3:0]][31] == 1) begin
	    psr[3] <= 1;
	    psr[4] <= 0;
	    end
	  else begin
	    psr[4:3] <= 0;
	    end
	  pc <= pc + 1'b1;
  end
endtask
endmodule
