--Latest version of all project files available at http://opencores.org/project,wrimm
--See License.txt for license details
--See WrimmManual.pdf for the Wishbone Datasheet and implementation details.
--See wrimm subversion project for version history

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
library wrimm;
	use wrimm.WrimmPackage.all;
	

entity Wb2MasterIntercon is
	generic (
		MasterCount				: integer := 1;
		StatusParams 			: StatusFieldDefType;
		SettingParams 		: SettingFieldDefType;
		TriggerParams			: TriggerFieldDefType);
	port (
		WbClk							: in	std_logic;
		WbRst							: out	std_logic;
		
		WbMasterIn				: in	WbMasterOutArray(0 to MasterCount-1);	--Signals from Masters
		WbMasterOut				: out	WbSlaveOutArray(0 to MasterCount-1);	--Signals to Masters
		
		WbSlaveIn				: out	WbMasterOutArray(0 to SlaveCount-1);
		WbSlaveOut				: in	WbSlaveOutArray(0 to SlaveCount-1)
		
		StatusRegs				:	in	StatusArrayType;
		SettingRegs				:	out	SettingArrayType;
		SettingRsts				: in	SettingArrayBitType;
		Triggers					: out	TriggerArrayType;
		TriggerClr				: in	TriggerArrayType;
		
		rstZ							: in	std_logic);													--Asynchronous reset
end entity Wb2MasterIntercon;

architecture behavior of Wb2MasterIntercon is
	signal	wbStrobe								: std_logic;
	signal	validAddress						: std_logic;
	signal	wbAddr									: WbAddrType;
	signal	wbSData,wbMData					: WbDataType;
	signal	wbWrEn,wbCyc						: std_logic;
	signal	wbAck,wbRty,wbErr				: std_logic;
	signal	wbMDataTag							: std_logic_vector(0 to 1);
	signal	wbCycType								: std_logic_vector(0 to 2);
	signal	iSettingRegs						: SettingArrayType;
	signal	iTriggers								: TriggerArrayType;
	signal	statusEnable						: StatusArrayBitType;
	signal	settingEnable						: SettingArrayBitType;
	signal	triggerEnable						: TriggerArrayType;
	signal	testEnable,testClr			: std_logic;
	signal	testNibble							: std_logic_vector(0 to 3);
	signal	grant										: std_logic_vector(0 to MasterCount-1);
  
begin
	SettingRegs	<= iSettingRegs;
	Triggers		<= iTriggers;

--=============================================================================
-------------------------------------------------------------------------------
--	Master Round Robin Arbitration
-------------------------------------------------------------------------------
	procArb: process(WbClk,rstZ) is	--Round robin arbitration (descending)
		variable vGrant : std_logic_vector(0 to MasterCount-1);
	begin
		if (rstZ='0') then
			grant(0) <= '1';
			grant(1 to MasterCount-1) <= (Others=>'0');
		elsif rising_edge(WbClk) then
			loopGrant: for i in 0 to (MasterCount-1) loop
				if vGrant(i)='1' and WbMasterIn(i).Cyc='0' then	--else maintain grant
					loopNewGrantA: for j in i to (MasterCount-1) loop --last master with cyc=1 will be selected
						if WbMasterIn(j).Cyc='1' then
							vGrant		:= (Others=>'0');
							vGrant(j)	:= '1';
						end if;
					end loop loopNewGrantA;
					if i/=0 then
						loopNewGrantB: for j in 0 to (i-1) loop
							if WbMasterIn(j).Cyc='0' then
								vGrant 		:= (Others=>'1');
								vGrant(j) := '1';
							end if;
						end loop loopNewGrantB;		--grant only moves after new requester
					end if;
				end if;
			end loop loopGrant;
			grant	<= vGrant;
		end if;	--Clk
	end process procArb;
--=============================================================================
-------------------------------------------------------------------------------
--	Master Mux
-------------------------------------------------------------------------------
	procWbIn: process(grant,WbMasterIn,wbSData,wbAck,wbErr,wbRty) is
		variable grantId		: integer;
	begin
		loopGrantMux: for i in 0 to (MasterCount-1) loop
			--if grant(i)='1' then
			--	grantId := i;
			--end if;
			grantID	<= grantID + ((2**i)*to_integer(unsigned(grant(i)),1));
			WbMasterOut(i).Ack	<= grant(i) and wbAck;
			WbMasterOut(i).Err	<= grant(i) and wbErr;
			WbMasterOut(i).Rty	<= grant(i) and wbRty;
			WbMasterOut(i).Data	<= wbSData;	--Data out can always be active.
		end loop loopGrantMux;
		wbStrobe 		<= WbMasterIn(grantId).Strobe;
		wbWrEn			<= WbMasterIn(grantId).WrEn;
		wbAddr			<= WbMasterIn(grantId).Addr;
		wbMData			<= WbMasterIn(grantId).Data;
		wbMDataTag	<= WbMasterIn(grantId).DataTag;
		wbCyc				<= WbMasterIn(grantId).Cyc;
		wbCycType		<= WbMasterIn(grantId).CycType;
	end process procWbIn;
	
	wbAck	<= wbStrobe and validAddress;
	wbErr	<= wbStrobe and not(validAddress);
	wbRty	<= '0';
	WbRst	<= '0';
--=============================================================================
-------------------------------------------------------------------------------
--	Address Decode, Asynchronous
-------------------------------------------------------------------------------
	procAddrDecode: process(wbAddr) is
		variable vValidAddress : std_logic;
	begin
			vValidAddress	:= '0';
			loopStatusEn: for f in StatusFieldType loop
				if StatusParams(f).Address=wbAddr then
					statusEnable(f)	<= '1';
					vValidAddress := '1';
				else
					statusEnable(f)	<= '0';
				end if;
			end loop loopStatusEn;
			loopSettingEn: for f in SettingFieldType loop
				if SettingParams(f).Address=wbAddr then
					settingEnable(f)	<= '1';
					vValidAddress := '1';
				else
					settingEnable(f)	<= '0';
				end if;
			end loop loopSettingEn;
			loopTriggerEn: for f in TriggerFieldType loop
				if TriggerParams(f).Address=wbAddr then
					triggerEnable(f)	<= '1';
					vValidAddress := '1';
				else
					triggerEnable(f)	<= '0';
				end if;
			end loop loopTriggerEn;
			validAddress	<= vValidAddress;
	end process procAddrDecode;
--=============================================================================
-------------------------------------------------------------------------------
--	Read
-------------------------------------------------------------------------------
	procRegRead: process(StatusRegs,iSettingRegs,iTriggers,statusEnable,settingEnable,triggerEnable) is
		variable vWbSData	: std_logic_vector(0 to 31);
	begin
		vWbSData	:= (Others=>'0');
		loopStatusRegs : for f in StatusFieldType loop
			if statusEnable(f)='1' then
				vWbSData(StatusParams(f).MSBLoc to (StatusParams(f).MSBLoc + StatusParams(f).BitWidth - 1))	:= StatusRegs(f)((WbDataBits-StatusParams(f).BitWidth) to WbDataBits-1);
			end if;	--Address
		end loop loopStatusRegs;
		loopSettingRegs : for f in SettingFieldType loop
			if settingEnable(f)='1' then
				vWbSData(SettingParams(f).MSBLoc to (SettingParams(f).MSBLoc + SettingParams(f).BitWidth - 1)) := iSettingRegs(f)((WbDataBits-SettingParams(f).BitWidth) to WbDataBits-1);
			end if;	--Address
		end loop loopSettingRegs;
		loopTriggerRegs : for f in TriggerFieldType loop
			if triggerEnable(f)='1' then
				vWbSData(TriggerParams(f).BitLoc)	:= iTriggers(f);
			end if;	--Address
		end loop loopTriggerRegs;
		wbSData	<= vWbSData;
	end process procRegRead;
--=============================================================================
-------------------------------------------------------------------------------
--	Write
-------------------------------------------------------------------------------
	procRegWrite: process(WbClk,rstZ) is
	begin
		if (rstZ='0') then
			loopSettingRegDefault : for f in SettingFieldType loop
				iSettingRegs(f)	<= SettingParams(f).Default;
			end loop loopSettingRegDefault;
			loopTriggerRegDefault : for f in TriggerFieldType loop
				iTriggers(f)	<= '0';
			end loop loopTriggerRegDefault;
		elsif rising_edge(WbClk) then
			loopSettingRegWr : for f in SettingFieldType loop
				if settingEnable(f)='1' and wbStrobe='1' and wbWrEn='1' then
					iSettingRegs(f)((WbDataBits-SettingParams(f).BitWidth) to WbDataBits-1) <= wbMData(SettingParams(f).MSBLoc to (SettingParams(f).MSBLoc + SettingParams(f).BitWidth-1));
				end if;
			end loop loopSettingRegWr;
			loopSettingRegRst : for f in SettingFieldType loop
				if SettingRsts(f)='1' then
					iSettingRegs(f)	<= SettingParams(f).Default;
				end if;
			end loop loopSettingRegRst;
			loopTriggerRegWr : for f in TriggerFieldType loop
				if triggerEnable(f)='1' and wbStrobe='1' and wbWrEn='1' then
					iTriggers(f)																			<= wbMData(TriggerParams(f).BitLoc);
				elsif TriggerClr(f)='1' then
					iTriggers(f)																			<= '0';
				end if;	--Address or clear
			end loop loopTriggerRegWr;
		end if;	--Clk
	end process procRegWrite;
	
	testEnable	<= settingEnable(SetIntegrationQStop);
	testClr			<= settingRsts(SetIntegrationQStop);
	testNibble	<= iSettingRegs(SetIntegrationQStop)(28 to 31);
			
end architecture behavior;