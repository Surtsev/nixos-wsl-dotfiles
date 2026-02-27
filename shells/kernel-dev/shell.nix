{ pkgs ? import <nixpkgs> {} }:

let
  kernelDev = pkgs.linuxPackages_6_12.kernel.dev;
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    kernelDev
    bear
    gnumake
    gcc
    kmod
  ];

  shellHook = ''
    export KERNEL_DEV=${kernelDev}
    export KERNELDIR=$KERNEL_DEV/lib/modules/*/build
    echo "KERNEL_DEV set to $KERNEL_DEV"
    echo "KERNELDIR set to $KERNELDIR"
    
    # Создаём симлинк для обратной совместимости
    if [ ! -e /run/current-system/kernel ]; then
      sudo ln -sf $KERNEL_DEV /run/current-system/kernel
    fi
  '';
}
