`include "defines.v"

module if_stage (
    input 	wire 					cpu_clk_50M,
    input 	wire 					cpu_rst_n,
    
    input   wire                    flush,  //�����ˮ���ź�
    input   wire [`INST_ADDR_BUS]   cp0_excaddr,    //�쳣���������ڵ�ַ
    
    input wire [`STALL_BUS]        stall,
    
    output  wire                     ice,
    output 	reg  [`INST_ADDR_BUS] 	pc,
    output 	wire [`INST_ADDR_BUS]	iaddr,
    
    //��תָ��
    input   wire [`INST_ADDR_BUS]   jump_addr_1,
    input   wire [`INST_ADDR_BUS]   jump_addr_2,
    input   wire [`INST_ADDR_BUS]   jump_addr_3,
    input   wire [`JTSEL_BUS    ]   jtsel,
    output  wire [`INST_ADDR_BUS]   pc_plus_4,
    
    //�쳣����
    output wire [`EXC_CODE_BUS]     if_exccode_o
    );
    
    wire [`INST_ADDR_BUS] pc_next; 
   
    
    
    //��תָ��
    assign pc_plus_4=(cpu_rst_n==`RST_ENABLE)?`PC_INIT:pc+4;
    
    assign pc_next = (jtsel == 2'b00)? pc_plus_4:   // ������һ��ָ��ĵ�ַ
                     (jtsel == 2'b01)?jump_addr_1:
                     (jtsel == 2'b10)?jump_addr_3:
                     (jtsel == 2'b11)?jump_addr_2:`PC_INIT;
    
     reg ce;                
    always @(posedge cpu_clk_50M) begin
		if (cpu_rst_n == `RST_ENABLE) begin
			ce <= `CHIP_DISABLE;		      // ��λ��ʱ��ָ��洢������  
		end else begin
			ce <= `CHIP_ENABLE; 		      // ��λ������ָ��洢��ʹ��
		end
	end
	
	assign ice = (stall[1] == 1'b1 || flush)?1'b0:ce;
	

    always @(posedge cpu_clk_50M) begin
        if (ce == `CHIP_DISABLE)
            pc <= `PC_INIT;                   // ָ��洢�����õ�ʱ��PC���ֳ�ʼֵ��MiniMIPS32������Ϊ0x00000000��
        else begin
            if(flush==1'b1)
                pc <= cp0_excaddr;
            else if(stall[0] == `NOSTOP) begin
                pc <= pc_next;                    // ָ��洢��ʹ�ܺ�PCֵÿʱ�����ڼ�4 	
            end
        end
    end
    
    assign iaddr = (ice == `CHIP_DISABLE) ? `PC_INIT : pc;    // ��÷���ָ��洢���ĵ�ַ
    
    assign if_exccode_o=(cpu_rst_n==`RST_ENABLE)?`EXC_NONE:
                        (iaddr[1:0]!=2'b00)?`EXC_ADEL:`EXC_NONE;

endmodule