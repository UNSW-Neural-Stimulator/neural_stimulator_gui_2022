//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <quick_blue_windows/quick_blue_windows_plugin.h>
#include <win_ble/win_ble_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  QuickBlueWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("QuickBlueWindowsPlugin"));
  WinBlePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WinBlePlugin"));
}
