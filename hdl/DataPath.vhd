--------------------------------------------------------------------------------
-- Module Name:     DataPath - Behavioral
-- Project Name:    RISCV32IM-implementation
-- Description:     Datapath of the 5-stage pipelined RISC-V processor, integrating 
--                  all components and pipeline registers. (modified)
--                  K. Myny en J. Vliegen, “Opleidingsonderdeel: Computer Architecturen”, 16 September 2024.
--
-- Revision     Date         Author               Comments
-- v0.2         25.03.2026   VlJo-MyKr-SaSu       Modified version
--------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.STD_LOGIC_ARITH.ALL;
    use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DataPath is
    port (
        clk         : in STD_LOGIC;
        rst         : in STD_LOGIC; --reset is button, must be debounced

        -- dmem
        dmem_dataOut : in STD_LOGIC_VECTOR(31 downto 0);
        dmem_writeEn : out STD_LOGIC_VECTOR(3 downto 0);
        dmem_Address : out STD_LOGIC_VECTOR(31 downto 0);
        dmem_dataIn  : out STD_LOGIC_VECTOR(31 downto 0);

        -- imem
        imem_instruction : in STD_LOGIC_VECTOR(31 downto 0);
        imem_Address : out STD_LOGIC_VECTOR(31 downto 0)
    );
end entity DataPath;

architecture Behavioral of DataPath is
    --------------------------------
    -- PIPELINE REGISTERS
    --------------------------------
    component BRD is
        Port ( 
            clk             : in STD_LOGIC;
            rst             : in STD_LOGIC;
            enable          : in STD_LOGIC;        
            flush           : in STD_LOGIC;
            PC_BRD_IN       : in STD_LOGIC_VECTOR(31 downto 0);
            PC4_BRD_IN      : in STD_LOGIC_VECTOR(31 downto 0);
            PC_BRD_OUT      : out STD_LOGIC_VECTOR(31 downto 0);
            PC4_BRD_OUT     : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    component if_id is
        port (
            clk					:in STD_LOGIC;
            rst					:in STD_LOGIC;
            enable				:in STD_LOGIC;
            flush				:in STD_LOGIC;
            
            instruction_if_in   :in STD_LOGIC_VECTOR(31 downto 0);
            PC_if_in			:in STD_LOGIC_VECTOR(31 downto 0);
            PC4_if_in			:in STD_LOGIC_VECTOR(31 downto 0);
            
            instruction_id_out  :out STD_LOGIC_VECTOR(31 downto 0);
            PC_id_out			:out STD_LOGIC_VECTOR(31 downto 0);
            PC4_id_out			:out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    component id_ex is
        Port (
            --INPUTS
            clk             : in STD_LOGIC;
            rst             : in STD_LOGIC;
            enable          : in STD_LOGIC;
            flush           : in STD_LOGIC;

            -- Data 
            data1_ID_IN     : in STD_LOGIC_VECTOR (31 downto 0);
            data2_ID_IN     : in STD_LOGIC_VECTOR (31 downto 0);

            newAddress_ID_IN: in STD_LOGIC_VECTOR (31 downto 0);

            PC_ID_IN        : in STD_LOGIC_VECTOR (31 downto 0);
            PC4_ID_IN       : in STD_LOGIC_VECTOR (31 downto 0);
            imm_ID_IN       : in STD_LOGIC_VECTOR (31 downto 0);

            -- Addresses of data
            instrRD_ID_IN   : in STD_LOGIC_VECTOR (4 downto 0);
            instrRS1_ID_IN  : in STD_LOGIC_VECTOR (4 downto 0);
            instrRS2_ID_IN  : in STD_LOGIC_VECTOR (4 downto 0);
            -- Exec
            StoreSel_ID_IN  : in STD_LOGIC_VECTOR (1 downto 0);
            ALUOp_ID_IN     : in STD_LOGIC_VECTOR (4 downto 0);
            ALUSrc2_ID_IN   : in STD_LOGIC;
            ALUSrc1_ID_IN   : in STD_LOGIC;
            -- Mem
            branch_ID_IN    : in STD_LOGIC_VECTOR (3 downto 0);
            MemRead_ID_IN   : in STD_LOGIC;
            MemWrite_ID_IN  : in STD_LOGIC;
            -- Wb
            MemtoReg_ID_IN  : in STD_LOGIC_VECTOR (2 downto 0);
            RegWrite_ID_IN  : in STD_LOGIC;
            LoadSel_ID_IN   : in STD_LOGIC_VECTOR (1 downto 0);
            
            --OUTPUTS
            -- Data 
            data1_EX_OUT     : out STD_LOGIC_VECTOR (31 downto 0);
            data2_EX_OUT     : out STD_LOGIC_VECTOR (31 downto 0);

            newAddress_EX_OUT: out STD_LOGIC_VECTOR (31 downto 0);

            PC_EX_OUT        : out STD_LOGIC_VECTOR (31 downto 0); 
            PC4_EX_OUT       : out STD_LOGIC_VECTOR (31 downto 0); 
            imm_EX_OUT       : out STD_LOGIC_VECTOR (31 downto 0);

            -- Addresses of data
            instrRD_EX_OUT   : out STD_LOGIC_VECTOR (4 downto 0);
            instrRS1_EX_OUT  : out STD_LOGIC_VECTOR (4 downto 0);
            instrRS2_EX_OUT  : out STD_LOGIC_VECTOR (4 downto 0);
            -- EX
            StoreSel_EX_OUT  : out STD_LOGIC_VECTOR (1 downto 0);
            ALUOp_EX_OUT     : out STD_LOGIC_VECTOR (4 downto 0);
            ALUSrc2_EX_OUT   : out STD_LOGIC;
            ALUSrc1_EX_OUT   : out STD_LOGIC;
            -- MEM
            branch_EX_OUT    : out STD_LOGIC_VECTOR (3 downto 0);
            MemRead_EX_OUT   : out STD_LOGIC;
            MemWrite_EX_OUT  : out STD_LOGIC;
            -- WB
            MemtoReg_EX_OUT  : out STD_LOGIC_VECTOR (2 downto 0);
            RegWrite_EX_OUT  : out STD_LOGIC;
            LoadSel_EX_OUT   : out STD_LOGIC_VECTOR (1 downto 0)
            );
    end component;

    component ex_mem is
    Port (
        --INPUTS
        clk                 : in STD_LOGIC;
        rst                 : in STD_LOGIC;
        enable              : in STD_LOGIC;
        flush               : in STD_LOGIC;

        -- Data
        result_EX_IN        : in STD_LOGIC_VECTOR (31 downto 0);
        dataIn_EX_IN        : in STD_LOGIC_VECTOR (31 downto 0); 
        product_EX_IN       : in STD_LOGIC_VECTOR (63 downto 0); 
        PC_EX_IN            : in STD_LOGIC_VECTOR (31 downto 0);
        PC4_EX_IN           : in STD_LOGIC_VECTOR (31 downto 0);

        -- Addresses of data
        instrRD_EX_IN       : in STD_LOGIC_VECTOR (4 downto 0);

        instrRS2_EX_IN      : in STD_LOGIC_VECTOR (4 downto 0);

        -- Mem
        MemWrite_EX_IN      : in STD_LOGIC;
        StoreSel_EX_IN      : in STD_LOGIC_VECTOR(1 downto 0);
        MemRead_EX_IN       : in STD_LOGIC;

        -- WB
        MemtoReg_EX_IN      : in STD_LOGIC_VECTOR (2 downto 0);
        RegWrite_EX_IN      : in STD_LOGIC;
        LoadSel_EX_IN       : in STD_LOGIC_VECTOR (1 downto 0);

        -- OUTPUTS
        -- Data
        result_MEM_OUT      : out STD_LOGIC_VECTOR (31 downto 0);

        dataIn_MEM_OUT      : out STD_LOGIC_VECTOR (31 downto 0); 
        product_MEM_OUT     : out STD_LOGIC_VECTOR (63 downto 0);
        PC_MEM_OUT          : out STD_LOGIC_VECTOR (31 downto 0);
        PC4_MEM_OUT         : out STD_LOGIC_VECTOR (31 downto 0);

        -- Addresses of data
        instrRD_MEM_OUT     : out STD_LOGIC_VECTOR (4 downto 0);
        
        instrRS2_MEM_OUT    : out STD_LOGIC_VECTOR (4 downto 0);
        
        -- Mem
        MemWrite_MEM_OUT    : out STD_LOGIC;
        StoreSel_MEM_OUT    : out STD_LOGIC_VECTOR(1 downto 0);
        MemRead_MEM_OUT     : out STD_LOGIC;

        -- WB
        MemtoReg_MEM_OUT    : out STD_LOGIC_VECTOR (2 downto 0);
        RegWrite_MEM_OUT    : out STD_LOGIC;
        LoadSel_MEM_OUT     : out STD_LOGIC_VECTOR (1 downto 0)
    );
end component;

    component mem_wb is
    port (
        --INPUTS
        clk              : in  STD_LOGIC;
        rst              : in  STD_LOGIC;
        enable           : in  STD_LOGIC;
        flush            : in  STD_LOGIC;

        -- Data
        dataOut_MEM_IN   : in  STD_LOGIC_VECTOR(31 downto 0);
        result_MEM_IN    : in  STD_LOGIC_VECTOR(31 downto 0);
        product_MEM_IN   : in  STD_LOGIC_VECTOR(63 downto 0);

        PC_MEM_IN        : in  STD_LOGIC_VECTOR(31 downto 0);
        PC4_MEM_IN       : in  STD_LOGIC_VECTOR(31 downto 0);

        -- Addresses
        instrRD_MEM_IN   : in  STD_LOGIC_VECTOR(4 downto 0);

        -- Wb control signals
        MemtoReg_MEM_IN  : in  STD_LOGIC_VECTOR(2 downto 0);
        RegWrite_MEM_IN  : in  STD_LOGIC;
        LoadSel_MEM_IN   : in  STD_LOGIC_VECTOR(1 downto 0);


        -- OUTPUTS
        -- Data
        dataOut_WB_OUT   : out STD_LOGIC_VECTOR(31 downto 0);
        result_WB_OUT    : out STD_LOGIC_VECTOR(31 downto 0);
        product_WB_OUT   : out STD_LOGIC_VECTOR(63 downto 0);

        PC_WB_OUT        : out STD_LOGIC_VECTOR(31 downto 0);
        PC4_WB_OUT       : out STD_LOGIC_VECTOR(31 downto 0);

        -- Addresses
        instrRD_WB_OUT   : out STD_LOGIC_VECTOR(4 downto 0);

        -- Wb control signals
        MemtoReg_WB_OUT  : out STD_LOGIC_VECTOR(2 downto 0);
        RegWrite_WB_OUT  : out STD_LOGIC;
        LoadSel_WB_OUT   : out STD_LOGIC_VECTOR(1 downto 0)
    );
end component;
    
    --------------------------------
    -- FORWARDING / HAZARD
    --------------------------------
    component Forwarding_Unit is
        port (
            --INPUTS
            -- Addresses of data
            instrRS1_EX_IN          : in STD_LOGIC_VECTOR (4 downto 0);
            instrRS2_EX_IN          : in STD_LOGIC_VECTOR (4 downto 0);
            instrRD_MEM_IN          : in STD_LOGIC_VECTOR (4 downto 0);     -- address of Rd from mem-stage
            instrRD_WB_IN           : in STD_LOGIC_VECTOR (4 downto 0);     -- address of Rd from writeback-stage

            instrRS2_MEM_IN          : in STD_LOGIC_VECTOR (4 downto 0);

            -- Control signals
            RegWrite_MEM_IN         : in STD_LOGIC;                         -- RegWrite signal from mem-stage
            RegWrite_WB_IN          : in STD_LOGIC;                         -- RegWrite signal from writeback-stage
            toRegister_MEM_IN       : in STD_LOGIC_VECTOR (2 downto 0);     -- toRegister signal from mem-stage

            MemWrite_MEM_IN         : in STD_LOGIC;


            --OUTPUTS
            forwardOp1_OUT          : out STD_LOGIC_VECTOR (1 downto 0);
            forwardOp2_OUT          : out STD_LOGIC_VECTOR (1 downto 0);
            forwardDataWbToMem_OUT  : out STD_LOGIC;
            forwardDataWbToEx_OUT   : out STD_LOGIC
        );
    end component;

    component Hazard_Detection_Unit is
        port (
            --INPUTS
            -- Addresses of data
            instrRS1_ID_IN          : in STD_LOGIC_VECTOR (4 downto 0);
            instrRS2_ID_IN          : in STD_LOGIC_VECTOR (4 downto 0);
            instrRD_EX_IN           : in STD_LOGIC_VECTOR (4 downto 0);     -- address of Rd from ex-stage
            -- Control signal
            MemRead_EX_IN           : in STD_LOGIC;                         -- MemRead signal from ex-stage
            MemWrite_ID_IN          : in STD_LOGIC;

            --OUTPUTS
            -- selectors
            noOpSelector_OUT        : out STD_LOGIC;
            IF_ID_stage_enable_OUT  : out STD_LOGIC
        );
    end component;

    --------------------------------
    -- OTHER COMPONENTS
    --------------------------------
    component multiplier is
        generic(size: INTEGER := 32);
            port (
                operator1   : in STD_LOGIC_VECTOR(size-1 downto 0);
                operator2   : in STD_LOGIC_VECTOR(size-1 downto 0);
                product     : out STD_LOGIC_VECTOR(2*size-1 downto 0)
            );
    end component;	 

    component PC is
        port (
            PCIn        : in STD_LOGIC_VECTOR(31 downto 0);
            clk         : in STD_LOGIC;
            rst         : in STD_LOGIC;
            PCEnable    : in STD_LOGIC;     -- PCEnable signal to include a hazard detection unit, which can stall the pipeline
            PCOut       : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    component Reg_File
        port (
            clk         :in STD_LOGIC;
            writeReg    :in STD_LOGIC;                     
            sourceReg1  :in STD_LOGIC_VECTOR(4 downto 0);  
            sourceReg2  :in STD_LOGIC_VECTOR(4 downto 0);  
            destinyReg  :in STD_LOGIC_VECTOR(4 downto 0);  
            data        :in STD_LOGIC_VECTOR(31 downto 0); 
            readData1   :out STD_LOGIC_VECTOR(31 downto 0);
            readData2   :out STD_LOGIC_VECTOR(31 downto 0) 
        );
    end component;

    component Mux
        port (
            muxIn0      :in STD_LOGIC_VECTOR(31 downto 0);
            muxIn1      :in STD_LOGIC_VECTOR(31 downto 0);
            selector    :in STD_LOGIC;
            muxOut      :out STD_LOGIC_VECTOR(31 downto 0)    
    );
    end component;

    component Mux4Input is
        port (
            muxIn0      :in STD_LOGIC_VECTOR(31 downto 0);
            muxIn1      :in STD_LOGIC_VECTOR(31 downto 0);
            muxIn2      :in STD_LOGIC_VECTOR(31 downto 0);
            muxIn3      :in STD_LOGIC_VECTOR(31 downto 0);
            selector    :in STD_LOGIC_VECTOR(1 downto 0);
            muxOut      :out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    component MuxPr is
    port (
        muxIn0      :in STD_LOGIC_VECTOR(31 downto 0);
        muxIn1      :in STD_LOGIC_VECTOR(31 downto 0);
        selector    :in STD_LOGIC_VECTOR(2 downto 0);
        muxOut      :out STD_LOGIC_VECTOR(31 downto 0)
    );
    end component;

    component ALU_RV32
        port (
            clk         :in STD_LOGIC;
            rst         :in STD_LOGIC;
            operator1   :in STD_LOGIC_VECTOR(31 downto 0);
            operator2   :in STD_LOGIC_VECTOR(31 downto 0);
            ALUOp       :in STD_LOGIC_VECTOR(4 downto 0);
            result      :out STD_LOGIC_VECTOR(31 downto 0);
            zero        :out STD_LOGIC;
            carryOut    :out STD_LOGIC;
            signo  		:out STD_LOGIC;
            divider_busy:out STD_LOGIC
        );
    end component;

    component Immediate_Generator
        port (
            instruction     : in STD_LOGIC_VECTOR(31 downto 0);
            immediate       : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    component Mux_Store
        port (
            muxIn0      :in STD_LOGIC_VECTOR(31 downto 0);  --SB
            muxIn1      :in STD_LOGIC_VECTOR(31 downto 0);  --SW
            selector    :in STD_LOGIC;
            muxOut      :out STD_LOGIC_VECTOR(31 downto 0)
    );
    end component;

    component Branch_Control
        port (
            branch              : in STD_LOGIC_VECTOR(3 downto 0);
            carry               : in STD_LOGIC;
            signo               : in STD_LOGIC;
            zero                : in STD_LOGIC;
            PCSrc               : out STD_LOGIC_VECTOR(1 downto 0);
            falsePredict_OUT    : out STD_LOGIC
        );
    end component;

    component Mux_ToRegFile is
        generic(
            busWidth    :integer := 32
            --selWidth    :integer := 3
        );
        port (
            muxIn0          :in STD_LOGIC_VECTOR(busWidth-1 downto 0);       --register
            muxIn1          :in STD_LOGIC_VECTOR(busWidth-1 downto 0);       --LB
            muxIn2          :in STD_LOGIC_VECTOR(busWidth-1 downto 0);       --LW
            muxIn3          :in STD_LOGIC_VECTOR(busWidth-1 downto 0);       --PC
            muxIn4          :in STD_LOGIC_VECTOR(busWidth-1 downto 0);       --mult
            muxIn5          :in STD_LOGIC_VECTOR(busWidth-1 downto 0);       --PC+4
            muxIn6          :in STD_LOGIC_VECTOR(busWidth-1 downto 0);       --mul
            muxIn7          :in STD_LOGIC_VECTOR(busWidth-1 downto 0);       --mulh
            selector        :in STD_LOGIC_VECTOR(2 downto 0);                --ToRegister
            loadSelector    :in STD_LOGIC_VECTOR(1 downto 0);                --LoadSel
            muxOut          :out STD_LOGIC_VECTOR(busWidth-1 downto 0)
        );
    end component;

    component Control
        port (
            opcode      : in STD_LOGIC_VECTOR(6 downto 0);
            funct3      : in STD_LOGIC_VECTOR(2 downto 0);
            funct7      : in STD_LOGIC_VECTOR(6 downto 0);
            jump        : out STD_LOGIC;
            ToRegister  : out STD_LOGIC_VECTOR(2 downto 0);
            MemWrite    : out STD_LOGIC;
            MemRead     : out STD_LOGIC;        -- veranderd subLab3
            Branch      : out STD_LOGIC_VECTOR(3 downto 0);
            ALUOp       : out STD_LOGIC_VECTOR(4 downto 0);
            StoreSel    : out STD_LOGIC_VECTOR(1 downto 0);
            ALUSrc1     : out STD_LOGIC;
            ALUSrc2     : out STD_LOGIC;
            WriteReg    : out STD_LOGIC;
            LoadSel     : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component;

    component Cond_delay is
        Port(
            clk             : in STD_LOGIC;
            rst             : in STD_LOGIC;
            enable          : in STD_LOGIC;
            memRead_MEM_IN  : in STD_LOGIC;

            stall_CD_OUT    : out STD_LOGIC
        );
    end component;

    component rst_after_jump is
        port (
            clk             : in  STD_LOGIC;
            rst             : in  STD_LOGIC;
            falsePredict    : in  STD_LOGIC;
            flush           : out STD_LOGIC
        );
    end component;

    component instr_control is
        port (
            clk          : in  STD_LOGIC;
            rst          : in  STD_LOGIC;
            stall        : in  STD_LOGIC;
            instr_sel    : out STD_LOGIC
        );
    end component;

    -- (DE-)LOCALISING IN/OUTPUTS
    ------------
    -- IF-stage
    ------------
    signal PCIn, PCOut_IfId_IN, PCOutPlus_IfId_IN, instruction_IfId_IN, instructionIfId_mux11, PC_BRD_IfId,
     PC4_BRD_IfId, jalr_address, current_instruction_IfId_IN, prev_instruction_IfId_IN                      : STD_LOGIC_VECTOR(31 downto 0);
    signal PCEnable_i, rstBackupReg, BRDIFID_enable_i, rst_after_jump_o, flushIfId, instr_sel_o : STD_LOGIC;
    
    ------------
    -- ID-stage
    ------------
    signal PCOut_IfId_IdEx, PCOutPlus_IfId_IdEx, instruction_IfId_OUT       : STD_LOGIC_VECTOR(31 downto 0);

    signal memRead, memWrite, jump, ALUSrc2, ALUSrc1, writeReg, IDEX_enable_i: STD_LOGIC;                        --veranderd subLab3 (extra memRead for HazarDdU)
    signal StoreSel                                                         : STD_LOGIC_VECTOR(1 downto 0);       
    signal toRegister                                                       : STD_LOGIC_VECTOR(2 downto 0);
    signal Branch                                                           : STD_LOGIC_VECTOR(3 downto 0);
    signal ALUOp                                                            : STD_LOGIC_VECTOR(4 downto 0);                             
    signal controlSignals, controlSignals_MuxOut                            : STD_LOGIC_VECTOR(31 downto 0);    --concatenation of control signals for mux
    signal loadSel                                                          : STD_LOGIC_VECTOR(1 downto 0);     --control signal voor load instructions

    signal immediate_IdEx_IN, offset, 
            regData1_IdEx_IN, regData2_IdEx_IN                              : STD_LOGIC_VECTOR(31 downto 0);   

    signal noOpSelector, Enable_IfId                                        : STD_LOGIC;                        -- Hazard detection unit output signals

    signal newAddress_IdEx_IN, shifted                                      : STD_LOGIC_VECTOR(31 downto 0);


    signal falsePredictPrev,falsePredictPrevPrev, BRDIFIDEnable_i_prev      : STD_LOGIC;

    ------------
    -- EX-stage
    ------------
    signal PCOut_IdEx_OUT, PCOutPlus_IdEx_ExMem                             : STD_LOGIC_VECTOR(31 downto 0);

    signal toRegister_IdEx_ExMem                                            : STD_LOGIC_VECTOR(2 downto 0);
    signal Branch_IdEx_OUT                                                  : STD_LOGIC_VECTOR(3 downto 0);
    signal memWrite_IdEx_ExMem, writeReg_IdEx_ExMem                         : STD_LOGIC;
    signal memRead_IdEx_ExMem                                                 : STD_LOGIC;                        -- enkel voor Hazard Unit, niet doorverbinden met volgende pipeline register

    signal ALUSrc2_IdEx_OUT, ALUSrc1_IdEx_OUT                               : STD_LOGIC;
    signal ALUOp_IdEx_OUT                                                   : STD_LOGIC_VECTOR(4 downto 0);
    signal loadSel_IdEx_ExMem, StoreSel_IdEx_OUT                            : STD_LOGIC_VECTOR(1 downto 0);

    signal immediate_IdEx_OUT,                                                                 -- (offset_IdEx_OUT=)PC+immediate after shift or result(jal)
            regData1_IdEx_OUT, regData2_IdEx_OUT                            : STD_LOGIC_VECTOR(31 downto 0);
    signal instrRS1_IdEx_OUT, instrRS2_IdEx_OUT, instrRD_IdEx_OUT           : STD_LOGIC_VECTOR(4 downto 0);

    signal forwardMuxOut_Op1, forwardMuxOut_Op2, op1, op2, 
            dataIn_ExMem_IN, result_ExMem_IN                                : STD_LOGIC_VECTOR(31 downto 0);    -- execution, data for memory, ALU result 

    signal signo_ExMem_IN, zero_ExMem_IN                                    : STD_LOGIC;                        -- ALU
    signal carry, div_busy                                                  : STD_LOGIC;                        -- ALU

    signal product_ExMem_IN                                                 : STD_LOGIC_VECTOR(63 downto 0);    -- output multiplier

    signal forwardOp1_Sel, forwardOp2_Sel                                   : STD_LOGIC_VECTOR(1 downto 0);     -- Forwarding unit                  
    signal forwardDataWbToMem_Sel                                           : STD_LOGIC;                        -- Forwarding unit
    signal forwardDataWbToEx_Sel                                            : STD_LOGIC;                        -- Forwarding unit

    signal newAddress_IdEx_OUT                                              : STD_LOGIC_VECTOR(31 downto 0);

    ------------
    -- MEM-stage
    ------------
    signal memWrite_ExMem_OUT, writeReg_ExMem_OUT, falsePredict, stall_CD,
            memRead_ExMem_OUT, MEMWB_enable_i                               : STD_LOGIC;
    signal StoreSel_ExMem_OUT                                               : STD_LOGIC_VECTOR(1 downto 0);     
    signal toRegister_ExMem_MemWb                                           : STD_LOGIC_VECTOR(2 downto 0);                                        

    signal PCOut_ExMem_MemWb, PCOutPlus_ExMem_MemWb                         : STD_LOGIC_VECTOR(31 downto 0);
    signal loadSel_ExMem_MemWb, PCSrc                                       : STD_LOGIC_VECTOR(1 downto 0);

    signal result_ExMem_OUT, dataIn_ExMem_OUT, dataIn, dataToStore          : STD_LOGIC_VECTOR(31 downto 0);
    --signal byte_i, halfword_i                                               : STD_LOGIC_VECTOR(31 downto 0);  
    signal instrRD_ExMem_OUT                                                : STD_LOGIC_VECTOR(4 downto 0);
    signal product_ExMem_OUT                                                : STD_LOGIC_VECTOR(31 downto 0);


    signal product_ExMem_MemWb                                              : STD_LOGIC_VECTOR(63 downto 0);   -- output multiplier

    signal dataOut_MemWb_IN                                                 : STD_LOGIC_VECTOR(31 downto 0);    -- output datamem

    signal instrRS2_ExMem_OUT                                               : STD_LOGIC_VECTOR(4 downto 0);

    signal we_4bit                                                          : STD_LOGIC_VECTOR(3 downto 0);

    ------------
    -- WB-stage
    ------------
    signal writeReg_MemWb_OUT                                               : STD_LOGIC;
    signal toRegister_MemWb_OUT                                             : STD_LOGIC_VECTOR(2 downto 0);
    signal loadSel_MemWb_OUT                                                : STD_LOGIC_VECTOR(1 downto 0);

    signal PCOut_MemWb_OUT, PCOutPlus_MemWb_OUT, dataOut_MemWb_OUT, 
            result_MemWb_OUT                                                : STD_LOGIC_VECTOR(31 downto 0);

    signal instrRD_MemWb_OUT                                                : STD_LOGIC_VECTOR(4 downto 0);

    signal product_MemWb_OUT                                                : STD_LOGIC_VECTOR(63 downto 0);

    signal dataForReg                                                       : STD_LOGIC_VECTOR(31 downto 0);



begin
    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
    imem_Address <= PCOut_IfId_IN; -- embedded imem (original design) => byte-addressed (15 downto 0) is ok, but for separate imem_model that reads from a file => word-addressed, so (17 downto 2), if slicing outside just full vector
    current_instruction_IfId_IN <= imem_instruction;

    dataOut_MemWb_IN <= dmem_dataOut; 
    dmem_writeEn <= we_4bit;
    dmem_Address <= result_ExMem_OUT;   --(15 downto 0) normal, if slicing outside just full vector
    dmem_dataIn <= dataIn;


    -------------------------------------------------------------------------------
    -- COMPONENTS MAPPING
    -------------------------------------------------------------------------------
    PCEnable_i <= (BRDIFID_enable_i or not(falsePredict));
    PCount: PC port map (clk => clk, rst => rst, PCIn => PCIn, PCEnable => PCEnable_i ,PCOut => PCOut_IfId_IN);
    
    Multipl: multiplier port map(operator1 => forwardMuxOut_Op1, operator2 => op2, product => product_ExMem_IN);

    RFILE: Reg_File port map (clk => clk, writeReg => writeReg_MemWb_OUT, sourceReg1 => instruction_IfId_OUT(19 downto 15),
    sourceReg2 => instruction_IfId_OUT(24 downto 20), destinyReg => instrRD_MemWb_OUT, data => dataForReg,
    readData1 => regData1_IdEx_IN, readData2 => regData2_IdEx_IN);
    
    ALU: ALU_RV32 port map (clk => clk, rst => rst, operator1 => op1, operator2 => op2, ALUOp => ALUOp_IdEx_OUT, 
    result => result_ExMem_IN, zero => zero_ExMem_IN, carryOut => carry, signo => signo_ExMem_IN, divider_busy => div_busy);

    BRControl: Branch_Control port map (branch => Branch_IdEx_OUT, carry => carry, signo => signo_ExMem_IN, zero => zero_ExMem_IN, PCSrc => PCSrc, falsePredict_OUT => falsePredict);

    MuxReg: Mux_ToRegFile port map (muxIn0 => result_MemWb_OUT, muxIn1 => dataOut_MemWb_OUT, muxIn2 => dataOut_MemWb_OUT, muxIn3 => PCOut_MemWb_OUT,
    muxIn4 => (others => '0'), muxIn5 => PCOutPlus_MemWb_OUT, muxIn6 => product_MemWb_OUT(31 downto 0), muxIn7 => product_MemWb_OUT(63 downto 32),
    selector => toRegister_MemWb_OUT, muxOut => dataForReg, loadSelector => loadSel_MemWb_OUT); 

    Ctrl: Control port map (opcode => instruction_IfId_OUT(6 downto 0), funct3 => instruction_IfId_OUT(14 downto 12), funct7 => instruction_IfId_OUT(31 downto 25),
    jump => jump, MemWrite => memWrite, MemRead => memRead, Branch => Branch, ALUOp => ALUOp, StoreSel => StoreSel, ALUSrc2 => ALUSrc2, ALUSrc1 => ALUSrc1, 
    WriteReg => WriteReg, ToRegister => toRegister, LoadSel => loadSel);    -- veranderd subLab3

    Imm: Immediate_Generator port map (instruction => instruction_IfId_OUT, immediate => immediate_IdEx_IN);


    ForwardingUnit: Forwarding_Unit
      port map (
        instrRS1_EX_IN          => instrRS1_IdEx_OUT,
        instrRS2_EX_IN          => instrRS2_IdEx_OUT,
        instrRD_MEM_IN          => instrRD_ExMem_OUT,
        instrRD_WB_IN           => instrRD_MemWb_OUT,
        instrRS2_MEM_IN         => instrRS2_ExMem_OUT,
        RegWrite_MEM_IN         => writeReg_ExMem_OUT,
        RegWrite_WB_IN          => writeReg_MemWb_OUT,
        forwardOp1_OUT          => forwardOp1_Sel,
        forwardOp2_OUT          => forwardOp2_Sel,
        forwardDataWbToMem_OUT  => forwardDataWbToMem_Sel,
        forwardDataWbToEx_OUT   => forwardDataWbToEx_Sel,
        toRegister_MEM_IN       => toRegister_ExMem_MemWb,
        MemWrite_MEM_IN         => memWrite_ExMem_OUT
      );

    HazardUnit: Hazard_Detection_Unit
      port map (
        instrRS1_ID_IN          => instruction_IfId_OUT(19 downto 15),
        instrRS2_ID_IN          => instruction_IfId_OUT(24 downto 20),
        instrRD_EX_IN           => instrRD_IdEx_OUT,
        MemRead_EX_IN           => memRead_IdEx_ExMem,
        MemWrite_ID_IN          => memWrite,
        noOpselector_OUT        => noOpSelector,
        IF_ID_stage_enable_OUT  => Enable_IfId
      );

    BRAM_DELAY2: Cond_delay port map (clk => clk, rst => rst, enable => '1', memRead_MEM_IN => memRead_ExMem_OUT, stall_CD_OUT => stall_CD);

    rst_after_jump_inst: rst_after_jump port map (clk => clk, rst => rst, falsePredict => falsePredict, flush => rst_after_jump_o);
    
    instruction_control: instr_control port map(clk => clk, rst => rst, stall => BRDIFID_enable_i, instr_sel => instr_sel_o);

    --------------------------------------------
    -- MUXES
    --------------------------------------------
    Mux0: Mux port map (muxIn0 => immediate_IdEx_OUT, muxIn1 => forwardMuxOut_Op2, selector => ALUSrc2_IdEx_OUT, muxOut => op2);
    Mux1: Mux port map (muxIn0 => regData2_IdEx_OUT, muxIn1 => dataForReg, selector => forwardDataWbToEx_Sel, muxOut => dataIn_ExMem_IN);
    Mux2: Mux port map (muxIn0 => immediate_IdEx_IN, muxIn1 => result_ExMem_IN, selector => jump, muxOut => offset);
    Mux3: Mux4Input port map (muxIn0 => PCOutPlus_IfId_IN, muxIn1 => newAddress_IdEx_OUT, muxIn2 => jalr_address, muxIn3 => (others => '0'), selector => PCSrc, muxOut => PCIn);
    jalr_address <= result_ExMem_IN and x"FFFFFFFE";

    Mux4: Mux port map (muxIn0 => controlSignals, muxIn1 => (others => '0'), selector => noOpSelector,muxOut => controlSignals_MuxOut);
    Mux5: Mux4Input port map (muxIn0 => regData1_IdEx_OUT, muxIn1 => dataForReg, muxIn2 => result_ExMem_OUT, muxIn3 => product_ExMem_OUT, selector => forwardOp1_Sel, muxOut => forwardMuxOut_Op1);
    Mux6: Mux4Input port map (muxIn0 => regData2_IdEx_OUT, muxIn1 => dataForReg, muxIn2 => result_ExMem_OUT, muxIn3 => product_ExMem_OUT, selector => forwardOp2_Sel, muxOut => forwardMuxOut_Op2);
    Mux7: Mux port map (muxIn0 => dataIn_ExMem_OUT, muxIn1 => dataForReg, selector => forwardDataWbToMem_Sel, muxOut => dataToStore);
    Mux8: Mux port map (muxIn0 => PCOut_IdEx_OUT, muxIn1 => forwardMuxOut_Op1, selector => ALUSrc1_IdEx_OUT, muxOut => op1); 
    
    Mux9: process( memWrite_ExMem_OUT, StoreSel_ExMem_OUT, result_ExMem_OUT, dataToStore )
    begin
        -- Default assignments to prevent latches
        we_4bit <= "0000";
        dataIn  <= dataToStore; 

        -- Only calculate if the 1-bit Write Enable is HIGH
        if memWrite_ExMem_OUT = '1' then
            
            case StoreSel_ExMem_OUT is
                when "00" => -- SW: Store Word
                    we_4bit <= "1111";       -- Enable all 4 bytes
                    dataIn  <= dataToStore;  -- Pass full 32-bit word

                when "01" => -- SB: Store Byte
                    -- Replicate the lowest byte across all 4 lanes (e.g., 0xAA becomes 0xAAAAAAAA)
                    dataIn <= dataToStore(7 downto 0) & dataToStore(7 downto 0) & 
                              dataToStore(7 downto 0) & dataToStore(7 downto 0);
                    
                    -- Use the address LSBs to enable only the correct physical byte lane in RAM
                    case result_ExMem_OUT(1 downto 0) is
                        when "00" => we_4bit <= "0001";
                        when "01" => we_4bit <= "0010";
                        when "10" => we_4bit <= "0100";
                        when "11" => we_4bit <= "1000";
                        when others => we_4bit <= "0000";
                    end case;

                when "10" => -- SH: Store Halfword
                    -- Replicate the lowest halfword across both lanes (e.g., 0xAABB becomes 0xAABBAABB)
                    dataIn <= dataToStore(15 downto 0) & dataToStore(15 downto 0);
                    
                    -- Use Address bit 1 to enable only the correct 16-bit lane in RAM
                    if result_ExMem_OUT(1) = '0' then
                        we_4bit <= "0011"; -- Lower halfword
                    else
                        we_4bit <= "1100"; -- Upper halfword
                    end if;

                when others =>
                    we_4bit <= "0000";
                    
            end case;
        end if;
    end process;

    MuxProduct: MuxPr port map(muxIn0 => product_ExMem_MemWb(31 downto 0), muxIn1 => product_ExMem_MemWb(63 downto 32),     
                                selector => toRegister_ExMem_MemWb, muxOut => product_ExMem_OUT);

    Mux10: Mux port map (muxIn0 => prev_instruction_IfId_IN, muxIn1 => current_instruction_IfId_IN, selector => instr_sel_o, muxOut => instructionIfId_mux11); 

    rstBackupReg <= rst and falsePredict;
    instruction_backup_reg: process (clk)
    begin
        if rising_edge(clk) then
            if rstBackupReg = '0' then
                prev_instruction_IfId_IN <= (others => '0');
            elsif instr_sel_o = '1' then
                prev_instruction_IfId_IN <= current_instruction_IfId_IN;
            end if;
        end if;
    end process;

    -- BUGFIX: Masks a 1-cycle BRAM delay duplicate instruction 
    -- that occurs when a MEM stall overlaps with a Branch misprediction flush.
    prevReg: process(clk)
    begin
        if rising_edge(clk) then
            falsePredictPrev <= falsePredict;
            falsePredictPrevPrev <= falsePredictPrev;
            BRDIFIDEnable_i_prev <= BRDIFID_enable_i;            
        end if;
    end process;
    
    Mux11: process(falsePredict, falsePredictPrev, falsePredictPrevPrev, PC_BRD_IfId, PC4_BRD_IfId, 
                    BRDIFIDEnable_i_prev, instructionIfId_mux11)
    begin
        if (falsePredictPrevPrev = '0' and falsePredictPrev = '0' and falsePredict = '1' and BRDIFIDEnable_i_prev = '1' 
                and PC_BRD_IfId = x"00000000" and PC4_BRD_IfId = x"00000000") then
            instruction_IfId_IN <= x"00000013"; -- NOP
        else
            instruction_IfId_IN <= instructionIfId_mux11;
        end if;
    end process;
    --------------------------------------------

    --------------------------------------------
    -- PIPELINE REGISTERS
    --------------------------------------------
    BRDIFID_enable_i <= (Enable_IfId and not(div_busy) and not(stall_CD));

    BRAM_DELAY1: BRD port map (clk => clk, rst => rst, enable => BRDIFID_enable_i, flush => falsePredict,
                                PC_BRD_IN => PCOut_IfId_IN, PC4_BRD_IN => PCOutPlus_IfId_IN, PC_BRD_OUT => PC_BRD_IfId, PC4_BRD_OUT => PC4_BRD_IfId);

    flushIfId <= falsePredict and rst_after_jump_o; -- reset for IF/ID register, triggered by jump instructions (to clear wrong-path instructions after a jump)
    IF_ID_REG: if_id
      port map (clk => clk, rst => rst, enable => BRDIFID_enable_i, instruction_if_in => instruction_IfId_IN, PC_if_in => PC_BRD_IfId, flush => flushIfId,
                PC4_if_in => PC4_BRD_IfId, instruction_id_out => instruction_IfId_OUT, PC_id_out => PCOut_IfId_IdEx, PC4_id_out => PCOutPlus_IfId_IdEx);

    IDEX_enable_i <= (not(div_busy) and not(stall_CD));
    ID_EX_REG: id_ex
      port map (clk => clk, rst => rst, enable => IDEX_enable_i, flush => falsePredict, data1_ID_IN => regData1_IdEx_IN, data2_ID_IN => regData2_IdEx_IN,
                newAddress_ID_IN => newAddress_IdEx_IN, PC_ID_IN => PCOut_IfId_IdEx, PC4_ID_IN => PCOutPlus_IfId_IdEx, imm_ID_IN => immediate_IdEx_IN,
                instrRD_ID_IN => instruction_IfId_OUT(11 downto 7), instrRS1_ID_IN => instruction_IfId_OUT(19 downto 15), instrRS2_ID_IN => instruction_IfId_OUT(24 downto 20),
                    StoreSel_ID_IN => controlSignals_MuxOut(1 downto 0), ALUOp_ID_IN => controlSignals_MuxOut(9 downto 5), ALUSrc2_ID_IN => controlSignals_MuxOut(3),
                    branch_ID_IN => controlSignals_MuxOut(17 downto 14), MemRead_ID_IN => controlSignals_MuxOut(13), MemWrite_ID_IN => controlSignals_MuxOut(4),
                    MemtoReg_ID_IN => controlSignals_MuxOut(12 downto 10), RegWrite_ID_IN => controlSignals_MuxOut(2), data1_EX_OUT => regData1_IdEx_OUT,
                data2_EX_OUT => regData2_IdEx_OUT, newAddress_EX_OUT => newAddress_IdEx_OUT, PC_EX_OUT => PCOut_IdEx_OUT, PC4_EX_OUT => PCOutPlus_IdEx_ExMem,
                imm_EX_OUT => immediate_IdEx_OUT, instrRD_EX_OUT => instrRD_IdEx_OUT, instrRS1_EX_OUT => instrRS1_IdEx_OUT, instrRS2_EX_OUT => instrRS2_IdEx_OUT,
                    StoreSel_EX_OUT => StoreSel_IdEx_OUT, ALUOp_EX_OUT => ALUOp_IdEx_OUT, ALUSrc2_EX_OUT => ALUSrc2_IdEx_OUT, branch_EX_OUT => Branch_IdEx_OUT,
                    MemRead_EX_OUT => memRead_IdEx_ExMem, MemWrite_EX_OUT => memWrite_IdEx_ExMem, MemtoReg_EX_OUT => toRegister_IdEx_ExMem, RegWrite_EX_OUT => writeReg_IdEx_ExMem,
                    ALUSrc1_ID_IN => controlSignals_MuxOut(18), ALUSrc1_EX_OUT => ALUSrc1_IdEx_OUT, LoadSel_ID_IN => controlSignals_MuxOut(20 downto 19), 
                    LoadSel_EX_OUT => loadSel_IdEx_ExMem);

    EX_MEM_REG: ex_mem
      port map (clk => clk, rst => rst, enable => IDEX_enable_i, flush => '1', result_EX_IN => result_ExMem_IN,
                dataIn_EX_IN => dataIn_ExMem_IN, product_EX_IN => product_ExMem_IN, PC_EX_IN => PCOut_IdEx_OUT,
                PC4_EX_IN => PCOutPlus_IdEx_ExMem, instrRD_EX_IN => instrRD_IdEx_OUT, MemWrite_EX_IN => memWrite_IdEx_ExMem,
                MemtoReg_EX_IN => toRegister_IdEx_ExMem, RegWrite_EX_IN => writeReg_IdEx_ExMem, result_MEM_OUT => result_ExMem_OUT,
                dataIn_MEM_OUT => dataIn_ExMem_OUT, product_MEM_OUT => product_ExMem_MemWb, PC_MEM_OUT => PCOut_ExMem_MemWb,
                PC4_MEM_OUT => PCOutPlus_ExMem_MemWb, instrRD_MEM_OUT => instrRD_ExMem_OUT, MemWrite_MEM_OUT => memWrite_ExMem_OUT,
                MemtoReg_MEM_OUT => toRegister_ExMem_MemWb, RegWrite_MEM_OUT => writeReg_ExMem_OUT, instrRS2_EX_IN => instrRS2_IdEx_OUT,
                instrRS2_MEM_OUT => instrRS2_ExMem_OUT, StoreSel_EX_IN => StoreSel_IdEx_OUT, StoreSel_MEM_OUT => StoreSel_ExMem_OUT,
                LoadSel_EX_IN => loadSel_IdEx_ExMem, LoadSel_MEM_OUT => loadSel_ExMem_MemWb, MemRead_EX_IN => memRead_IdEx_ExMem, MemRead_MEM_OUT => memRead_ExMem_OUT);

    MEMWB_enable_i <= (not(stall_CD));
    MEM_WB_REG: mem_wb
      port map (
        clk             => clk,
        rst             => rst,
        enable          => MEMWB_enable_i, -- pipeline enable signal
        flush           => '1',

        -- Input signals from MEM stage
        dataOut_MEM_IN  => dataOut_MemWb_IN,
        result_MEM_IN   => result_ExMem_OUT,
        product_MEM_IN  => product_ExMem_MemWb,
        PC_MEM_IN       => PCOut_ExMem_MemWb,
        PC4_MEM_IN      => PCOutPlus_ExMem_MemWb,
        instrRD_MEM_IN  => instrRD_ExMem_OUT,
        MemtoReg_MEM_IN => toRegister_ExMem_MemWb,
        RegWrite_MEM_IN => writeReg_ExMem_OUT,
        LoadSel_MEM_IN  => loadSel_ExMem_MemWb,

        -- Output signals to WB stage
        dataOut_WB_OUT  => dataOut_MemWb_OUT,
        result_WB_OUT   => result_MemWb_OUT,
        product_WB_OUT  => product_MemWb_OUT,
        PC_WB_OUT       => PCOut_MemWb_OUT,
        PC4_WB_OUT      => PCOutPlus_MemWb_OUT,
        instrRD_WB_OUT  => instrRD_MemWb_OUT,
        MemtoReg_WB_OUT => toRegister_MemWb_OUT,
        RegWrite_WB_OUT => writeReg_MemWb_OUT,
        LoadSel_WB_OUT  => loadSel_MemWb_OUT);
    --------------------------------------------

    PCOutPlus_IfId_IN <= PCOut_IfId_IN + 4;
    controlSignals <= "00000000000" & loadSel & ALUSrc1 & Branch & memRead & toRegister & ALUOp & memWrite & ALUSrc2 & writeReg & StoreSel;  --concatenation of all control signals
    --EXPLANATION OF CONTROLSIGNALS
    -------------------------------------------------------------------------------------------------------------------
    --  loadSel  -  ALUSrc1  -  Branch  -  memRead  -  toRegister  -  ALUOp  -  memWrite  -  ALUSrc2  -  writeReg  -  StoreSel = controlSignals
    --     |           |           |          |             |            |          |           |           |            | 
    --   '00'    -    '0'    -  '0000'   -   '0'     -    '000'     - '00000'  -   '0'     -   '0'    -    '0'     -    '00'    = "00000000000000000"
    --  (20->19) -   (18)   -  (17->14) -   (13)    -    (12->10)    -  (9->5) -   (4)     -   (3)    -    (2)     -   (1->0)   : index = 21 bits
    -------------------------------------------------------------------------------------------------------------------

    shifted <= offset(30 downto 0) & '0';
    newAddress_IdEx_IN <= PCOut_IfId_IdEx + shifted;
    

end architecture Behavioral;