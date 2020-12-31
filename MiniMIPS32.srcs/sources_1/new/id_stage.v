`include "defines.v"

module id_stage(
    input  wire                     cpu_rst_n,
    
    // ��ȡָ�׶λ�õ�PCֵ
    input  wire [`INST_ADDR_BUS]    id_pc_i,

    // ��ָ��洢��������ָ����
    input  wire [`INST_BUS     ]    id_inst_i,

    // ��ͨ�üĴ����Ѷ��������� 
    input  wire [`REG_BUS      ]    rd1,
    input  wire [`REG_BUS      ]    rd2,
      
    // ����ִ�н׶ε�������Ϣ
    output wire [`ALUTYPE_BUS  ]    id_alutype_o,
    output wire [`ALUOP_BUS    ]    id_aluop_o,
    output wire                     id_whilo_o,
    output wire                     id_mreg_o,
    output wire [`REG_ADDR_BUS ]    id_wa_o,
    output wire                     id_wreg_o,
    output wire [`REG_BUS]          id_din_o,

    // ����ִ�н׶ε�Դ������1��Դ������2
    output wire [`REG_BUS      ]    id_src1_o,
    output wire [`REG_BUS      ]    id_src2_o,
      
    // ������ͨ�üĴ����Ѷ˿ڵ�ʹ�ܺ͵�ַ
    output wire                     rreg1,
    output wire [`REG_ADDR_BUS ]    ra1,
    output wire                     rreg2,
    output wire [`REG_ADDR_BUS ]    ra2,
    
    /*-------------------- ����ǰ�� --------------------*/
    //��ִ�н׶λ�õ�д���ź�
    input wire                      exe2id_wreg,
    input wire [`REG_ADDR_BUS]      exe2id_wa,
    input wire [`INST_BUS]          exe2id_wd,
    //�ӷô�׶λ�õ�д���ź�
    input wire                      mem2id_wreg,
    input wire [`REG_ADDR_BUS]      mem2id_wa,
    input wire [`INST_BUS]          mem2id_wd,
    
    /*-------------------- ��תָ�� --------------------*/
    input wire [`INST_ADDR_BUS]     pc_plus_4,
    
    output wire [`INST_ADDR_BUS]    jump_addr_1,
    output wire [`INST_ADDR_BUS]    jump_addr_2,
    output wire [`INST_ADDR_BUS]    jump_addr_3,
    output wire [`JTSEL_BUS    ]    jtsel,
    output wire [`INST_ADDR_BUS]    ret_addr,
    
    //��ִ�н׶κͷô�׶λش��Ĵ洢�����Ĵ���ʹ���ź�
    input wire                      exe2id_mreg,
    input wire                      mem2id_mreg,
    
    //��ͣ�����ź�
    output wire                     stallreq_id,
    
    //�쳣����
    input  wire                     id_in_delay_i,
    input  wire                     flush_im,
    output wire [`REG_ADDR_BUS]     cp0_addr,
    output wire [`INST_ADDR_BUS]    id_pc_o,
    output wire                     id_in_delay_o,
    output wire                     next_delay_o,
    output wire [`EXC_CODE_BUS]     id_exccode_o,
    input wire [`EXC_CODE_BUS]     id_exccode_i
    );
    
    //�쳣����
    assign id_pc_o = (cpu_rst_n == `RST_ENABLE)?`PC_INIT: id_pc_i;
    assign id_in_delay_o = (cpu_rst_n == `RST_ENABLE)? 1'b0:id_in_delay_i;
    
    // ����С��ģʽ��ָ֯����
    wire [`INST_BUS] id_inst = (flush_im == `FLUSH)? `ZERO_WORD: {id_inst_i[7:0], id_inst_i[15:8], id_inst_i[23:16], id_inst_i[31:24]};

    // ��ȡָ�����и����ֶε���Ϣ
    wire [5 :0] op   = id_inst[31:26];
    wire [5 :0] func = id_inst[5 : 0];
    wire [4 :0] rd   = id_inst[15:11];
    wire [4 :0] rs   = id_inst[25:21];
    wire [4 :0] rt   = id_inst[20:16];
    wire [4 :0] sa   = id_inst[10: 6];
    wire [15:0] imm  = id_inst[15: 0]; 

    /*-------------------- ��һ�������߼���ȷ����ǰ��Ҫ�����ָ�� --------------------*/
    wire inst_reg  = ~|op;//opȫ0��regΪ1
    wire inst_and  = inst_reg& func[5]&~func[4]&~func[3]& func[2]&~func[1]&~func[0];
    
    //10.27 ����15������תָ��
    wire inst_subu = inst_reg& func[5]&~func[4]&~func[3]&~func[2]& func[1]& func[0];
    wire inst_slt = inst_reg& func[5]&~func[4]& func[3]&~func[2]& func[1]&~func[0];
    wire inst_add = inst_reg& func[5]&~func[4]&~func[3]&~func[2]&~func[1]&~func[0];
    wire inst_mult = inst_reg&~func[5]& func[4]& func[3]&~func[2]&~func[1]&~func[0];
    wire inst_mfhi = inst_reg&~func[5]& func[4]&~func[3]&~func[2]&~func[1]&~func[0];
    wire inst_mflo = inst_reg&~func[5]& func[4]&~func[3]&~func[2]& func[1]&~func[0];
    wire inst_sll = inst_reg&~func[5]&~func[4] &~func[3]&~func[2]&~func[1]&~func[0];
    wire inst_ori =~op[5]&~op[4]&op[3]&op[2]&~op[1]&op[0];
    wire inst_lui =~op[5]&~op[4]&op[3]& op[2]& op[1]& op[0];
    wire inst_addiu=~op[5]&~op[4]& op[3]& ~op[2]&~op[ 1]& op[0];
    wire inst_sltiu=~op[5]&~op[4]& op[3]&~op[2]& op[1]& op[0];
    wire inst_lb =op[5]&~op[4]&~op[3]&~op[2]&~op[0];
    wire inst_lw =op[5]&~op[4]&~op[3] &~op[2]& op[1]& op[0];
    wire inst_sb =op[5]&~op[4]& op[3]&~op[2]&~op[1]&~op[0];
    wire inst_sw =op[5]&~op[4]& op[3]&~op[2]&op[1]&op[0];
    
    //11.8 ����22����ת��ָ��
    wire inst_addu = inst_reg& func[5]&~func[4]&~func[3]&~func[2]& ~func[1]& func[0];
    wire inst_sub = inst_reg& func[5]&~func[4]&~func[3]&~func[2]& func[1]& ~func[0];
    wire inst_sltu = inst_reg& func[5]&~func[4]&func[3]&~func[2]& func[1]& func[0];
    wire inst_or = inst_reg& func[5]&~func[4]&~func[3]&func[2]& ~func[1]& func[0];
    wire inst_nor = inst_reg& func[5]&~func[4]&~func[3]&func[2]& func[1]& func[0];
    wire inst_xor = inst_reg& func[5]&~func[4]&~func[3]&func[2]& func[1]& ~func[0];
    wire inst_srl = inst_reg& ~func[5]& ~func[4]& ~func[3]& ~func[2]& func[1]& ~func[0];
    wire inst_sra = inst_reg& ~func[5]& ~func[4]& ~func[3]& ~func[2]& func[1]& func[0];
    wire inst_sllv = inst_reg& ~func[5]& ~func[4]& ~func[3]& func[2]& ~func[1]& ~func[0];
    wire inst_srlv = inst_reg& ~func[5]& ~func[4]& ~func[3]& func[2]& func[1]& ~func[0];
    wire inst_srav = inst_reg& ~func[5]& ~func[4]& ~func[3]& func[2]& func[1]& func[0];
    wire inst_multu = inst_reg& ~func[5]& func[4]& func[3]& ~func[2]& ~func[1]& func[0];
    wire inst_mthi = inst_reg& ~func[5]& func[4]& ~func[3]& ~func[2]& ~func[1]& func[0];
    wire inst_mtlo = inst_reg& ~func[5]& func[4]& ~func[3]& ~func[2]& func[1]& func[0];
    wire inst_addi = ~op[5]& ~op[4]& op[3]& ~op[2]& ~op[1]& ~op[0];
    wire inst_slti = ~op[5]& ~op[4]& op[3]& ~op[2]& op[1]& ~op[0];
    wire inst_andi = ~op[5]& ~op[4]& op[3]& op[2]& ~op[1]& ~op[0];
    wire inst_xori = ~op[5]& ~op[4]& op[3]& op[2]& op[1]& ~op[0];
    wire inst_lbu = op[5]& ~op[4]& ~op[3]& op[2]& ~op[1]& ~op[0];
    wire inst_lh = op[5]& ~op[4]& ~op[3]& ~op[2]& ~op[1]& op[0];
    wire inst_lhu = op[5]& ~op[4]& ~op[3]& op[2]& ~op[1]& op[0];
    wire inst_sh = op[5]& ~op[4]& op[3]& ~op[2]& ~op[1]& op[0];
    
    //11.13 ����5��ת��ָ��
    wire inst_j = ~op[5]& ~op[4]& ~op[3]& ~op[2]& op[1]& ~op[0];
    wire inst_jal = ~op[5]& ~op[4]& ~op[3]& ~op[2]& op[1]& op[0];
    wire inst_jr = inst_reg &~func[5]& ~func[4]& func[3]& ~func[2]& ~func[1]& ~func[0];
    wire inst_beq = ~op[5]& ~op[4]& ~op[3]& op[2]& ~op[1]& ~op[0];
    wire inst_bne = ~op[5]& ~op[4]& ~op[3]& op[2]& ~op[1]& op[0];
    
    //12.14 ����7��ת��ָ��
    wire inst_jalr = inst_reg &~func[5]& ~func[4]& func[3]& ~func[2]& ~func[1]& func[0];
    wire inst_bgez = ~op[5]& ~op[4]& ~op[3]& ~op[2]& ~op[1]& op[0]& ~id_inst[20]& id_inst[16];
    wire inst_bgtz = ~op[5]& ~op[4]& ~op[3]& op[2]& op[1]& op[0];
    wire inst_blez = ~op[5]& ~op[4]& ~op[3]& op[2]& op[1]& ~op[0];
    wire inst_bltz = ~op[5]& ~op[4]& ~op[3]& ~op[2]& ~op[1]& op[0]& ~id_inst[20]& ~id_inst[16];
    wire inst_bgezal = ~op[5]& ~op[4]& ~op[3]& ~op[2]& ~op[1]& op[0]& id_inst[20]& id_inst[16];
    wire inst_bltzal = ~op[5]& ~op[4]& ~op[3]& ~op[2]& ~op[1]& op[0]& id_inst[20]& ~id_inst[16];
    
    //12.14 ������������ָ��
    wire inst_div = inst_reg &~func[5]& func[4]& func[3]& ~func[2]& func[1]& ~func[0];
    wire inst_divu = inst_reg &~func[5]& func[4]& func[3]& ~func[2]& func[1]& func[0];    
    
    //12.15 ���������쳣����
    wire inst_syscall = inst_reg &~func[5]& ~func[4]& func[3]& func[2]& ~func[1]& ~func[0];
    wire inst_eret = ~op[5]& op[4]& ~op[3]& ~op[2]& ~op[1]& ~op[0] &~func[5]& func[4]& func[3]& ~func[2]& ~func[1]& ~func[0] ;
    wire inst_mfc0 = ~op[5]& op[4]& ~op[3]& ~op[2]& ~op[1]& ~op[0] & ~id_inst[23];
    wire inst_mtc0 = ~op[5]& op[4]& ~op[3]& ~op[2]& ~op[1]& ~op[0] & id_inst[23];
    /*------------------------------------------------------------------------------*/
    /*-------------------- �ڶ��������߼������ɾ�������ź� --------------------*/
    // ��������alutype
    assign id_alutype_o[2] =(cpu_rst_n == `RST_ENABLE)? 1'b0: (inst_sll |inst_srl |inst_sra |inst_sllv |inst_srlv |inst_srav
                            | inst_j | inst_jal | inst_jr | inst_beq | inst_bne | inst_jalr |inst_bgez | inst_bgtz | inst_blez
                            | inst_bltz | inst_bgezal | inst_bltzal | inst_syscall | inst_eret | inst_mtc0 );
    assign id_alutype_o[1] =(cpu_rst_n == `RST_ENABLE)?1'b0:(inst_and | inst_mfhi | inst_mflo | inst_ori | inst_lui
                            | inst_or | inst_nor | inst_xor |  inst_andi | inst_xori | inst_eret | inst_mfc0 | inst_mtc0);
    assign id_alutype_o[0] =(cpu_rst_n ==`RST_ENABLE)?1'b0: (inst_add | inst_subu | inst_slt | inst_mfhi | inst_mflo
                            | inst_addiu | inst_sltiu | inst_lb |inst_lw | inst_sb | inst_sw
                            | inst_addu | inst_sub | inst_sltu | inst_mthi | inst_mtlo | inst_addi | inst_slti | inst_lbu 
                            | inst_lh | inst_lhu | inst_sh | inst_j | inst_jal | inst_jr | inst_beq | inst_bne | inst_jalr |inst_bgez | inst_bgtz | inst_blez
                            | inst_bltz | inst_bgezal | inst_bltzal | inst_mfc0);
    //�ڲ�������aluop
    assign id_aluop_o[7] =(cpu_rst_n ==`RST_ENABLE)? 1'b0: (inst_lb | inst_lw | inst_sb | inst_sw | inst_syscall | inst_eret | inst_mfc0 | inst_mtc0);
    assign id_aluop_o[6]=(cpu_rst_n ==`RST_ENABLE)? 1'b0:(inst_addu | inst_sub | inst_sltu | inst_or | inst_nor 
                         | inst_xor | inst_srl| inst_sra | inst_sllv | inst_srlv | inst_srav | inst_multu 
                         |  inst_mthi | inst_mtlo | inst_addi | inst_slti | inst_andi | inst_xori | inst_lbu 
                         | inst_lh |inst_lhu | inst_sh);
    assign id_aluop_o[5] =(cpu_rst_n == `RST_ENABLE)? 1'b0: (inst_slt | inst_sltiu | inst_j | inst_jal 
                            | inst_jr | inst_beq | inst_bne | inst_jalr |inst_bgez | inst_bgtz | inst_blez
                            | inst_bltz | inst_bgezal | inst_bltzal);
    assign id_aluop_o[4] =(cpu_rst_n ==`RST_ENABLE)? 1'b0:
     (inst_add | inst_subu | inst_and | inst_mult | inst_sll |
     inst_ori | inst_addiu | inst_lb | inst_lw | inst_sb | inst_sw
     | inst_andi | inst_xori | inst_lbu | inst_lh |inst_lhu | inst_sh
     | inst_beq | inst_bne| inst_jalr |inst_bgez | inst_bgtz | inst_blez
     | inst_bltz | inst_bgezal | inst_bltzal | inst_div | inst_divu);
    assign id_aluop_o[3]=(cpu_rst_n==`RST_ENABLE)?1'b0:
     (inst_add | inst_subu | inst_and | inst_mfhi | inst_mflo |
     inst_ori | inst_addiu | inst_sb | inst_sw
     | inst_sllv | inst_srlv | inst_srav | inst_multu 
     |  inst_mthi | inst_mtlo | inst_addi | inst_slti | inst_j | inst_jal 
     | inst_jr | inst_bltzal | inst_mfc0 | inst_mtc0 );
    assign id_aluop_o[2]=(cpu_rst_n==`RST_ENABLE)?1'b0:
     (inst_slt | inst_and | inst_mult | inst_mfhi | inst_mflo|
     inst_ori | inst_lui | inst_sltiu | inst_nor 
     | inst_xor | inst_srl| inst_sra |  inst_mthi | inst_mtlo
     | inst_addi | inst_slti |inst_lhu | inst_sh
     | inst_j | inst_jal | inst_jr | inst_bgtz | inst_blez
     | inst_bltz | inst_bgezal| inst_div | inst_divu
     | inst_syscall | inst_eret | inst_mfc0 | inst_mtc0);
     assign id_aluop_o[1] =(cpu_rst_n ==`RST_ENABLE)? 1'b0:
     (inst_subu | inst_slt | inst_sltiu | inst_lw | inst_sw
     | inst_sltu | inst_or | inst_srl| inst_sra | inst_srav | inst_multu
     | inst_addi | inst_slti | inst_lbu | inst_lh | inst_jal
     | inst_jalr |inst_bgez | inst_bltz | inst_bgezal | inst_div | inst_divu
     | inst_syscall | inst_eret);
     assign id_aluop_o[0] =(cpu_rst_n ==`RST_ENABLE)?1'b0:
     (inst_subu | inst_mflo | inst_sll |
    inst_ori | inst_lui | inst_addiu | inst_sltiu
    | inst_sub | inst_or  | inst_xor | inst_sra | inst_srlv | inst_multu 
    | inst_mtlo  | inst_slti  | inst_xori 
    | inst_lh | inst_sh | inst_jr | inst_bne
    |inst_bgez | inst_blez | inst_bgezal | inst_divu
    | inst_mtc0 | inst_eret);


    //дͨ�üĴ���ʹ���ź�
    assign id_wreg_o=(cpu_rst_n == `RST_ENABLE)?1'b0:
    (inst_add | inst_subu | inst_slt | inst_and | inst_mfhi | inst_mflo | inst_sll |
    inst_ori | inst_lui | inst_addiu | inst_sltiu | inst_lb | inst_lw
    |inst_addu | inst_sub | inst_sltu | inst_or | inst_nor 
    | inst_xor | inst_srl| inst_sra | inst_sllv | inst_srlv | inst_srav
    | inst_addi | inst_slti | inst_andi | inst_xori | inst_lbu 
    | inst_lh |inst_lhu  | inst_jal |inst_jalr | inst_bgezal | inst_bltzal | inst_mfc0);
    //дHILO�Ĵ���ʹ���ź�
    assign id_whilo_o =(cpu_rst_n == `RST_ENABLE)?1'b0:(inst_mult| inst_multu 
                             |  inst_mthi | inst_mtlo | inst_div | inst_divu) ;
                             

    //��λʹ��ָ��
    wire shift =inst_sll| inst_srl| inst_sra ;
    //������ʹ���ź�
    wire immsel = inst_ori | inst_lui | inst_addiu | inst_sltiu | inst_lb | inst_lw | inst_sb | inst_sw
                  | inst_addi | inst_slti | inst_andi | inst_xori | inst_lbu 
                  | inst_lh |inst_lhu | inst_sh;

    //Ŀ�ļĴ���ѡ���ź�
    wire rtsel=inst_ori | inst_lui | inst_addiu | inst_sltiu | inst_lb | inst_lw
                | inst_addi | inst_slti | inst_andi | inst_xori | inst_lbu 
                            | inst_lh |inst_lhu ;
    //������չʹ���ź�
    wire sext =inst_addiu | inst_sltiu | inst_lb | inst_lw | inst_sb | inst_sw
                | inst_addi | inst_slti | inst_lbu 
                | inst_lh |inst_lhu | inst_sh;
    //���ظ߰���ʹ���ź�
    wire upper =inst_lui;
    //�洢�����Ĵ���ʹ���ź�
    assign id_mreg_o =(cpu_rst_n == `RST_ENABLE)? 1'b0: (inst_lb | inst_lw| inst_lbu 
                             | inst_lh |inst_lhu );
    //��ͨ�üĴ����Ѷ˿�1ʹ���ź�
    assign rreg1=(cpu_rst_n == `RST_ENABLE)?1'b0:
                                 (inst_add | inst_subu | inst_slt | inst_and | inst_mult|
                                inst_ori | inst_addiu | inst_sltiu | inst_lb | inst_lw | inst_sb | inst_sw
                             | inst_addu | inst_sub | inst_sltu | inst_or | inst_nor 
                             | inst_xor | inst_sllv | inst_srlv | inst_srav | inst_multu 
                             |  inst_mthi | inst_mtlo| inst_addi | inst_slti | inst_andi | inst_xori | inst_lbu 
                             | inst_lh |inst_lhu | inst_sh | inst_jr | inst_beq |inst_bne | inst_jalr |inst_bgez 
                             | inst_bgtz | inst_blez | inst_bltz | inst_bgezal | inst_bltzal | inst_div | inst_divu);
    //��ͨ�üĴ����Ѷ��˿�2ʹ���ź�
    assign rreg2=(cpu_rst_n==`RST_ENABLE)?1'b0:
                              (inst_add | inst_subu | inst_slt | inst_and | inst_mult | inst_sll | inst_sb | inst_sw
                              | inst_addu | inst_sub | inst_sltu | inst_or | inst_nor 
                              | inst_xor | inst_srl| inst_sra | inst_sllv | inst_srlv | inst_srav | inst_multu |inst_sh
                              | inst_beq |inst_bne | inst_div | inst_divu | inst_mtc0 );
    //�����ӳ�������ź�
    wire jal=inst_jal | inst_bgezal | inst_bltzal | inst_jalr;
    

    
    //����Դ������ѡ���ź�
    wire [1:0] fwrd1 = (cpu_rst_n==`RST_ENABLE)? 2'b00:
                        (exe2id_wreg == `WRITE_ENABLE && exe2id_wa == ra1 && rreg1 ==`READ_ENABLE)?2'b01:
                        (mem2id_wreg == `WRITE_ENABLE && mem2id_wa == ra1 && rreg1 ==`READ_ENABLE)?2'b10:
                        (rreg1 ==`READ_ENABLE)?2'b11:2'b00;
                        
    wire [1:0] fwrd2 = (cpu_rst_n==`RST_ENABLE)? 2'b00:
                        (exe2id_wreg == `WRITE_ENABLE && exe2id_wa == ra2 && rreg2 ==`READ_ENABLE)?2'b01:
                        (mem2id_wreg == `WRITE_ENABLE && mem2id_wa == ra2 && rreg2 ==`READ_ENABLE)?2'b10:
                        (rreg2 ==`READ_ENABLE)?2'b11:2'b00;
    /*------------------------------------------------------------------------------*/

    // ��ͨ�üĴ����Ѷ˿�1�ĵ�ַΪrs�ֶΣ����˿�2�ĵ�ַΪrt�ֶ�
    assign ra1 =(cpu_rst_n == `RST_ENABLE)? `ZERO_WORD: rs;
    assign ra2 =(cpu_rst_n ==`RST_ENABLE)? `ZERO_WORD:rt;
    //���ָ����������������
    wire [31: 0] imm_ext=(cpu_rst_n ==`RST_ENABLE)? `ZERO_WORD:
    (upper == `UPPER_ENABLE )?(imm<<16):
    (sext ==`SIGNED_EXT)?{{16{imm[15]}},imm}:{{16{1'b0}},imm};
    //��ô�д��Ŀ�ļĴ����ĵ�ַ(rt��rd)
    assign id_wa_o =(cpu_rst_n ==`RST_ENABLE)? `ZERO_WORD :
                    (rtsel ==`RT_ENABLE || inst_mfc0 )? rt:
                    (jal == 1'd1     )? 5'b11111:rd;
    //��÷ô�׶�Ҫ�������ݴ洢��������(����ͨ�üĴ����Ѷ����ݶ˿�2)
    assign id_din_o =(cpu_rst_n ==`RST_ENABLE)? `ZERO_WORD: 
                     (fwrd2 == 2'b01)?exe2id_wd:
                     (fwrd2 == 2'b10)?mem2id_wd:
                     (fwrd2 == 2'b11)? rd2:`ZERO_WORD;
    //���Դ������1����� shift�ź���Ч,��Դ������1Ϊ��λλ��,����Ϊ�Ӷ�ͨ�üĴ����Ѷ˿�1��õ�����
    assign id_src1_o =(cpu_rst_n == `RST_ENABLE)? `ZERO_WORD:
    (shift ==`SHIFT_ENABLE )?{27'b0, sa}:
    (fwrd1 ==2'b01 )? exe2id_wd:
    (fwrd1 ==2'b10 )? mem2id_wd:
     (fwrd1 ==2'b11 )? rd1: `ZERO_WORD;
    //���Դ������2����� immsel�ź���Ч,��Դ������1Ϊ������,����Ϊ�Ӷ�ͨ�üĴ����Ѷ˿�2��õ�����
    assign id_src2_o =(cpu_rst_n == `RST_ENABLE)? `ZERO_WORD:
    (immsel ==`IMM_ENABLE )?imm_ext:
    (fwrd2 ==2'b01 )? exe2id_wd:
    (fwrd2 ==2'b10 )? mem2id_wd:
     (fwrd2 ==2'b11 )? rd2: `ZERO_WORD;
     
    //�������ʹ���ź�
     wire equ =(cpu_rst_n == `RST_ENABLE)?1'b0:
                (inst_beq)?(id_src1_o == id_src2_o):
                (inst_bne)?(id_src1_o != id_src2_o):
                (inst_bgez)?($signed(id_src1_o) >= 0):
                (inst_bgtz)?($signed(id_src1_o) > 0):
                (inst_blez)?($signed(id_src1_o) <= 0):
                (inst_bltz)?($signed(id_src1_o) < 0):
                (inst_bgezal)?($signed(id_src1_o) >= 0):
                (inst_bltzal)?($signed(id_src1_o) < 0):1'b0;
               
    //����ת�Ƶ�ַѡ���ź�
                assign jtsel[1]=inst_jr | inst_beq & equ | inst_bne & equ | inst_bgez& equ | inst_bgtz& equ | inst_blez& equ
                                | inst_bltz& equ | inst_bgezal& equ | inst_bltzal& equ | inst_jalr;
                assign jtsel[0]=inst_j | inst_jal | inst_beq & equ | inst_bne & equ| inst_bgez& equ | inst_bgtz& equ | inst_blez& equ
                                | inst_bltz& equ | inst_bgezal& equ | inst_bltzal& equ;
    
    //���ɼ���ת�Ƶ�ַ�����ź�
    wire [`INST_ADDR_BUS] pc_plus_8=pc_plus_4+4;
    wire [`JUMP_BUS     ] instr_index =id_inst[25:0];
    wire [`INST_ADDR_BUS] imm_jump={{14{imm[15]}},imm,2'b00};
    
    //���ת�Ƶ�ַ
    assign jump_addr_1 ={pc_plus_4[31:28],instr_index,2'b00};
    assign jump_addr_2 =pc_plus_4+imm_jump;
    assign jump_addr_3 =id_src1_o;
    
    //�����ӳ�����õķ��ص�ַ
    assign ret_addr =pc_plus_8;
    
    assign stallreq_id = (cpu_rst_n==`RST_ENABLE)? `NOSTOP:
                         (((exe2id_wreg == `WRITE_ENABLE && exe2id_wa == ra1 && rreg1 == `READ_ENABLE)||
                         (exe2id_wreg == `WRITE_ENABLE && exe2id_wa == ra2 && rreg2 == `READ_ENABLE))&&
                         (exe2id_mreg == 1'b1))?`STOP:
                         (((mem2id_wreg == `WRITE_ENABLE && mem2id_wa == ra1 && rreg1 == `READ_ENABLE)||
                         (mem2id_wreg == `WRITE_ENABLE && mem2id_wa == ra2 && rreg2 == `READ_ENABLE))&&
                         (mem2id_mreg == 1'b1))?`STOP:`NOSTOP;           
    assign next_delay_o=(cpu_rst_n==`RST_ENABLE)? 1'b0:
                        (inst_j | inst_jr | inst_jal | inst_beq | inst_bne |inst_bgez | inst_bgtz | inst_blez | inst_bltz | inst_bgezal | inst_bltzal | inst_jalr);
                        
    wire is_unknow = inst_and  |  inst_subu | inst_slt |
                        inst_add |
                        inst_mult |
                        inst_mfhi |
                        inst_mflo |
                        inst_sll |
                        inst_ori |
                        inst_lui|
                        inst_addiu |
                        inst_sltiu |
                        inst_lb |
                        inst_lw |
                        inst_sb |
                        inst_sw |
                        inst_addu |
                        inst_sub |
                        inst_sltu |
                        inst_or |
                        inst_nor |
                        inst_xor |
                        inst_srl |
                        inst_sra |
                        inst_sllv |
                        inst_srlv |
                        inst_srav |
                        inst_multu |
                        inst_mthi |
                        inst_mtlo |
                        inst_addi |
                        inst_slti |
                        inst_andi |
                        inst_xori|
                        inst_lbu |
                        inst_lh |
                        inst_lhu |
                        inst_sh|
                        inst_j |
                        inst_jal |
                        inst_jr |
                        inst_beq |
                        inst_bne |
                        inst_jalr|
                        inst_bgez |
                        inst_bgtz |
                        inst_blez |
                        inst_bltz |
                        inst_bgezal|
                        inst_bltzal |
                        inst_div |
                        inst_divu |
                        inst_syscall |
                        inst_eret |
                        inst_mfc0 |
                        inst_mtc0 ;

    assign id_exccode_o=(cpu_rst_n==`RST_ENABLE)?`EXC_NONE:
                        (inst_syscall == 1'b1)?`EXC_SYS:
                        (inst_eret == 1'b1)?`EXC_ERET:
                        (is_unknow == 0)?`EXC_RI:id_exccode_i;
    assign cp0_addr = (cpu_rst_n==`RST_ENABLE)?`REG_NOP:rd;                               
endmodule
