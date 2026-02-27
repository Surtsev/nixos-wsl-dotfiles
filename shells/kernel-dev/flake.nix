{
  description = "Kernel module development shells";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    kernel-dev-flake.url = "github:jordanisaacs/kernel-development-flake";
  };

  outputs = { self, nixpkgs, kernel-dev-flake }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      mkKernelDevShell = { kernelPackages, shellName }:
        pkgs.mkShell {
          name = shellName;

          buildInputs = with pkgs; [
            kernelPackages.kernel.dev
            bear
            gnumake
            gcc
            gdb
            kmod
            neovim
          ];

          shellHook = ''
            export KERNEL_DEV="${kernelPackages.kernel.dev}"
            export KERNEL_VERSION="${kernelPackages.kernel.modDirVersion}"
            export KERNEL_SRC="$KERNEL_DEV/lib/modules/$KERNEL_VERSION/build"
            export KERNEL_OUT="$HOME/.kernel-build-$KERNEL_VERSION"

            echo "🔧 Entering development shell: ${shellName}"
            echo "📁 Kernel source: $KERNEL_SRC"
            echo "📁 Kernel out: $KERNEL_OUT"
            echo "📌 Kernel version: $KERNEL_VERSION"

            mkdir -p "$KERNEL_OUT"

            # Копируем конфигурацию текущего ядра, если её нет
            if [ ! -f "$KERNEL_OUT/.config" ] && [ -f /proc/config.gz ]; then
                echo "⚙️  Copying kernel config to $KERNEL_OUT/.config"
                zcat /proc/config.gz > "$KERNEL_OUT/.config"
            fi

            # Генерируем недостающие файлы (auto.conf и др.)
            if [ -f "$KERNEL_OUT/.config" ] && [ ! -f "$KERNEL_OUT/include/config/auto.conf" ]; then
                echo "⚙️  Generating kernel build files (olddefconfig)..."

                # Копируем минимально необходимые файлы для работы Kconfig
                mkdir -p "$KERNEL_OUT/scripts"
                mkdir -p "$KERNEL_OUT/include"

                # Копируем основные файлы и директории (разрешаем ошибки копирования)
                cp -r "$KERNEL_SRC/scripts" "$KERNEL_OUT/" 2>/dev/null || true
                cp -r "$KERNEL_SRC/Kconfig" "$KERNEL_OUT/" 2>/dev/null || true
                cp -r "$KERNEL_SRC/arch" "$KERNEL_OUT/" 2>/dev/null || true
                cp -r "$KERNEL_SRC/include" "$KERNEL_OUT/" 2>/dev/null || true
                cp -r "$KERNEL_SRC/Makefile" "$KERNEL_OUT/" 2>/dev/null || true
                cp -r "$KERNEL_SRC/.gitignore" "$KERNEL_OUT/" 2>/dev/null || true

                # Копируем дополнительные необходимые поддиректории
                cp -r "$KERNEL_SRC/init" "$KERNEL_OUT/" 2>/dev/null || true
                cp -r "$KERNEL_SRC/kernel" "$KERNEL_OUT/" 2>/dev/null || true
                cp -r "$KERNEL_SRC/mm" "$KERNEL_OUT/" 2>/dev/null || true
                cp -r "$KERNEL_SRC/fs" "$KERNEL_OUT/" 2>/dev/null || true
                cp -r "$KERNEL_SRC/ipc" "$KERNEL_OUT/" 2>/dev/null || true
                cp -r "$KERNEL_SRC/security" "$KERNEL_OUT/" 2>/dev/null || true
                cp -r "$KERNEL_SRC/crypto" "$KERNEL_OUT/" 2>/dev/null || true
                cp -r "$KERNEL_SRC/block" "$KERNEL_OUT/" 2>/dev/null || true
                cp -r "$KERNEL_SRC/lib" "$KERNEL_OUT/" 2>/dev/null || true

                # Создаём ссылку на исходники для совместимости
                ln -sfn "$KERNEL_SRC" "$KERNEL_OUT/source" 2>/dev/null || true

                # Теперь запускаем olddefconfig в выходной директории
                cd "$KERNEL_OUT"
                make olddefconfig
                cd - > /dev/null
            fi

            export KERNEL_BUILD="$KERNEL_OUT"

            alias nvim='nvim -u ~/.config/nvim/init.lua'
          '';
        };
    in {
      devShells.${system} = {
        default = mkKernelDevShell {
          kernelPackages = pkgs.linuxPackages_latest;
          shellName = "kernel-dev-latest";
        };
        test = mkKernelDevShell {
          kernelPackages = pkgs.linuxPackages_6_12;  # ядро 6.12
          shellName = "kernel-dev-6.12";
        };
      };
    };
}
