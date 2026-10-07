#!/bin/sh

if [ -d "build" ]; then
    rm -rf build
fi

# Compile translations (.po -> .mo) so source installs are localized
python3 ./kpac i18n --no-merge

# Install widget and C++ plugin for current user
#
# NOTE: For the C++ plugin to work add the `QML_IMPORT_PATH` environment variable
# in `$HOME/.config/plasma-workspace/env/path.sh`:
# export QML_IMPORT_PATH="$HOME/.local/lib64/qml:$HOME/.local/lib/qml:$QML_IMPORT_PATH"
#
# For more information see https://userbase.kde.org/Session_Environment_Variables
cmake -B build/ -S . -DINSTALL_PLASMOID=ON -DBUILD_PLUGIN=ON -DCMAKE_INSTALL_PREFIX="$HOME/.local"
cmake --build build/
cmake --install build/
# cmake plasma_install_package does't copy executable permission
chmod 700 "$HOME/.local/share/plasma/plasmoids/luisbocanegra.audio.visualizer/contents/ui/tools/commandMonitor"
