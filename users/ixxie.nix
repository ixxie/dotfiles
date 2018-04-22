{ pkgs, ... }:

{
	users.extraUsers =
	{
		ixxie =
		{
			home = "/home/ixxie";
			extraGroups = [ "wheel" "networkmanager" ];
			isNormalUser = true;
			uid = 1000;
		};
	};
}
