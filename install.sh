#!/bin/sh

if [ -d "build" ]; then
    rm -rf build
fi

# Compile translations (.po -> .mo) so source installs are localized
python3 ./kpac i18n --no-merge

# Install widget for current user
cmake -B build/plasmoid -S . -DINSTALL_PLASMOID=ON -DCMAKE_INSTALL_PREFIX="$HOME/.local"
cmake --build build/plasmoid
cmake --install build/plasmoid

# cmake plasma_install_package does't copy executable permission
chmod 700 "$HOME/.local/share/plasma/plasmoids/luisbocanegra.audio.visualizer/contents/ui/tools/commandMonitor"

# Install plugin system-wide (required for qml modules)
cmake -B build/plugin -S . -DBUILD_PLUGIN=ON -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build/plugin
sudo cmake --install build/plugin
