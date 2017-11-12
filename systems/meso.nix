{ config, pkgs, ... }: 


{

    # Enter hostname (network name for the machine configuration).
    networking.hostName = "meso"; 

    # Set your time zone.
    time.timeZone = "Europe/Helsinki";

    # Set path for flux
    environment.variables =
        {
            FLUX_HOME = [ "/home/ixxie/Documents/fluxstack" ];

            SCRIPT_DIR = [ "/home/ixxie/Documents/scripts" ];
        };


    ####################
    # Network Settings #
    ####################

    programs.ssh.knownHosts = 
        [
            {
                hostNames = [ "fluxbox" "95.85.35.107" ];
                publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDSqFcWCfmICQMPN/GelrtbW7gqUF4ePPL/OrGSMK0mJUVW4TcU9WxyVywdKaluCawvKo24VmSAfpG+7suplWdnnPCwA+Oi3fbSBIY3GDBLTB7M4QD1Nb5jlvUhAedq4uFWXf2TVMKER8kPp1zepshA9cAim/P+0rjDVOog//C+rJx0rr7cpQ0TLb5LTGgoTcoC7ZlxMsDz9Jbj+h/mHewBJS5LfcaJLiY7yKb3O3gYmGKtVjxHvINya6e9Bnje8HPbhQ8zR/a9C/U/r1EXmcXBUJTGZcg9SGaHPN0iH/xFwsObv+E7s+XoyIPh6j6uWdTL+h0lx7LLWPts+xgijCtVr1IiCRkiDXgi+girZARMg4AZLM8mBsrTdSptOAxgzleO3mGJEztGmwCIXfyb9T/2QLCbo0G1Y559EbZeokZO9lJVBtO1x1KvfvjKvwMztRJfeUbIbxGrpmejKnB+efgaBNsUB000rfbQM1SL+z530LS0iC4lOGrQ1YQ6UCZgmRbqAep9k8SIQLjrloXaBiXdV7Ai+tUqOz5iqtjbiRTilXwfDO7nSf5nLpkc6Jel+q6quq9bBZKsEA8GgdrNb/SpWQX/njC8fe/HmN9yr3Ihw5LJT1sYMnQRQtyOe7kIpUlVuVNW807it8riT3OEIETgxB0iuW8CfXJ0UZmHCmAJbw==";
            }
        ];
    
    networking.extraHosts = "95.85.35.107 fluxbox";

    #####################
    # Hardware Settings #
    #####################
    
    imports =
        [
            ./meso-hardware-config.nix
            ./efiboot.nix
        ];

    hardware.enableAllFirmware = true;

    # Mouse Button Mapping (maps middle to left button)
    services.xserver.libinput.buttonMapping = "1 1 3 4 5 6 7 8 9";

    # Removes psmouse error on boot
    boot.blacklistedKernelModules = [ "psmouse" ];

}