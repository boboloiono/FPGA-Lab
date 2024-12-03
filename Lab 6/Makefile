all:
	quartus_map --read_settings_files=on --write_settings_files=off DE0_Nano -c DE0_Nano
	quartus_fit --read_settings_files=off --write_settings_files=off DE0_Nano -c DE0_Nano
	quartus_asm --read_settings_files=off --write_settings_files=off DE0_Nano -c DE0_Nano
	quartus_sta DE0_Nano -c DE0_Nano
