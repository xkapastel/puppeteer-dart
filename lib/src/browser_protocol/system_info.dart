/// The SystemInfo domain defines methods and events for querying low-level system information.

import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../connection.dart';

class SystemInfoManager {
  final Session _client;

  SystemInfoManager(this._client);

  /// Returns information about the system.
  Future<GetInfoResult> getInfo() async {
    await _client.send('SystemInfo.getInfo');
  }
}

class GetInfoResult {
  /// Information about the GPUs on the system.
  final GPUInfo gpu;

  /// A platform-dependent description of the model of the machine. On Mac OS, this is, for example, 'MacBookPro'. Will be the empty string if not supported.
  final String modelName;

  /// A platform-dependent description of the version of the machine. On Mac OS, this is, for example, '10.1'. Will be the empty string if not supported.
  final String modelVersion;

  /// The command line string used to launch the browser. Will be the empty string if not supported.
  final String commandLine;

  GetInfoResult({
    @required this.gpu,
    @required this.modelName,
    @required this.modelVersion,
    @required this.commandLine,
  });
}

/// Describes a single graphics processor (GPU).
class GPUDevice {
  /// PCI ID of the GPU vendor, if available; 0 otherwise.
  final num vendorId;

  /// PCI ID of the GPU device, if available; 0 otherwise.
  final num deviceId;

  /// String description of the GPU vendor, if the PCI ID is not available.
  final String vendorString;

  /// String description of the GPU device, if the PCI ID is not available.
  final String deviceString;

  GPUDevice({
    @required this.vendorId,
    @required this.deviceId,
    @required this.vendorString,
    @required this.deviceString,
  });

  Map toJson() {
    Map json = {
      'vendorId': vendorId.toString(),
      'deviceId': deviceId.toString(),
      'vendorString': vendorString.toString(),
      'deviceString': deviceString.toString(),
    };
    return json;
  }
}

/// Provides information about the GPU(s) on the system.
class GPUInfo {
  /// The graphics devices on the system. Element 0 is the primary GPU.
  final List<GPUDevice> devices;

  /// An optional dictionary of additional GPU related attributes.
  final Object auxAttributes;

  /// An optional dictionary of graphics features and their status.
  final Object featureStatus;

  /// An optional array of GPU driver bug workarounds.
  final List<String> driverBugWorkarounds;

  GPUInfo({
    @required this.devices,
    this.auxAttributes,
    this.featureStatus,
    @required this.driverBugWorkarounds,
  });

  Map toJson() {
    Map json = {
      'devices': devices.map((e) => e.toJson()).toList(),
      'driverBugWorkarounds':
          driverBugWorkarounds.map((e) => e.toString()).toList(),
    };
    if (auxAttributes != null) {
      json['auxAttributes'] = auxAttributes.toJson();
    }
    if (featureStatus != null) {
      json['featureStatus'] = featureStatus.toJson();
    }
    return json;
  }
}