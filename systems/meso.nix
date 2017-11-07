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
                hostNames = [ "fluxbox" "146.185.168.233" ];
                publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDsfwuc3IrwTuDK7gvitib/DEEKDMryIREERBE/KvsAgtCMILfDX/R/3YZgWnKs1mCvSqdqmQnnblhWCWYIm7mzn0QAs5z3D47gnV9w6C7A3f0xcaiND9Nz5UKJOwlqhuOCqRJ/YhoOB9iXemlonWq1igsrDPgjW4qdN1rB0v4Plx5PfElRgRUZ6RjmL1gZfiFRh0s+5ttE679IeJnWcnFOFSCCc2YA85ReJMOz+2ZowJWcoWI6kXq3pHPKZ01Yj1l6M0pAw22u4HvHf1hRIYkHbLadHpx+9U/m9ZBI7R4L0Jf+wdGJ67tIWzV58v8UGiqbUe/3+un0Ykdupf3fkUBlTtgJv25JvYVwnPBnz9hkFQASZD0GXNRNnw33uqtmRjUh38Ss9cf+aP0AIYlGipRnWgkuNUtSrL87m7SniTsDNyr+pVLjYpieGHPGoDpyFv9q24DOy4oQyv313h7O8ZL4GhHWBIKEroBjX2gvHHYD4bUz6xb5XGUXiXxPA/zJWeAeJtkQUdjGFHHFqUTBvSt26erMolCKMsxPycYIvISLxRI68DsYSttQVISgLp+FSd0vKeoJIPm47seGcZ48zZexOz2AJZSVi4RwrG37VN01QHZqCIAkXUStC1K3Qbo4e4iXgpLdAIMppvIIvYG/6GxeyJoom8wgPcJbKiUrkgtlBQ==";
            }
        ];
    
    networking.extraHosts = "146.185.168.233 fluxbox";

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