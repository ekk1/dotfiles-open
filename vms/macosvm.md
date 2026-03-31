# macOS 原生极简虚拟机

## Prepare

virtio 驱动去 Fedora 官网下载
https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso

TPM 限制则是在安装时候跳过

Shift + F10
regedit
HKEY_LOCAL_MACHINE\SYSTEM\Setup
新建 LabConfig 项
新建两个值 DWORD (32位)
BypassTPMCheck = 1
BypassSecureBootCheck = 1

磁盘驱动在
virtio-win.iso 的 viostor/w11/ARM64

网络跳过也是
Shift + F10
OOBE\BYPASSNRO

宿主机准备就是
xcode-select --install
mkdir -p ~/VM/Win11
vim ~/VM/Win11/main.swift
cd ~/VM/Win11
swiftc main.swift -o win11vm

cat > ~/VM/Win11/entitlements.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.virtualization</key>
    <true/>
</dict>
</plist>
EOF

codesign --entitlements entitlements.plist --force -s - win11vm
./win11vm

Linux 基本也是一样，改改几个写死的文件的地址就好了，其他自己看情况调整

```swift
import Foundation
import AppKit
import Virtualization

// =====================
// 配置区：改这里，改完重新编译
// =====================

let installMode = true

let vmDir = URL(fileURLWithPath: NSHomeDirectory())
    .appendingPathComponent("VM/Win11", isDirectory: true)

let windowsISO = vmDir.appendingPathComponent("windows.iso")
let virtioISO  = vmDir.appendingPathComponent("virtio-win.iso")
let diskImage  = vmDir.appendingPathComponent("disk.img")
let efiStore   = vmDir.appendingPathComponent("efi-vars.bin")
let machineIDFile = vmDir.appendingPathComponent("machine-id.bin")

let diskSize: UInt64       = 80 * 1024 * 1024 * 1024   // 80 GiB
let wantedMemory: UInt64   = 8 * 1024 * 1024 * 1024    // 8 GiB
let wantedCPUCount         = 8
let displayWidth           = 1280
let displayHeight          = 720

// =====================

func clamp<T: Comparable>(_ v: T, _ lo: T, _ hi: T) -> T { min(max(v, lo), hi) }

func ensureDir(_ url: URL) throws {
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
}

func ensureDisk(_ url: URL, size: UInt64) throws {
    guard !FileManager.default.fileExists(atPath: url.path) else { return }
    FileManager.default.createFile(atPath: url.path, contents: nil)
    let handle = try FileHandle(forWritingTo: url)
    try handle.truncate(atOffset: size)
    try handle.close()
}

func requireFile(_ url: URL, _ name: String) throws {
    guard FileManager.default.fileExists(atPath: url.path) else {
        throw NSError(domain: "VM", code: 1, userInfo: [
            NSLocalizedDescriptionKey: "\(name) 不存在: \(url.path)"
        ])
    }
}

func loadOrCreateMachineID(at url: URL) throws -> VZGenericMachineIdentifier {
    if let data = try? Data(contentsOf: url),
       let id = VZGenericMachineIdentifier(dataRepresentation: data) {
        return id
    }
    let id = VZGenericMachineIdentifier()
    try id.dataRepresentation.write(to: url)
    return id
}

func loadOrCreateEFI(at url: URL) throws -> VZEFIVariableStore {
    if FileManager.default.fileExists(atPath: url.path) {
        return VZEFIVariableStore(url: url)
    }
    return try VZEFIVariableStore(creatingVariableStoreAt: url)
}

func makeConfig() throws -> VZVirtualMachineConfiguration {
    try ensureDir(vmDir)
    try ensureDisk(diskImage, size: diskSize)

    if installMode {
        try requireFile(windowsISO, "Windows ISO")
        try requireFile(virtioISO, "Virtio ISO")
    }

    let c = VZVirtualMachineConfiguration()

    c.cpuCount = clamp(wantedCPUCount,
        VZVirtualMachineConfiguration.minimumAllowedCPUCount,
        VZVirtualMachineConfiguration.maximumAllowedCPUCount)

    c.memorySize = clamp(wantedMemory,
        VZVirtualMachineConfiguration.minimumAllowedMemorySize,
        VZVirtualMachineConfiguration.maximumAllowedMemorySize)

    // 平台
    let platform = VZGenericPlatformConfiguration()
    platform.machineIdentifier = try loadOrCreateMachineID(at: machineIDFile)
    c.platform = platform

    // EFI 引导
    let boot = VZEFIBootLoader()
    boot.variableStore = try loadOrCreateEFI(at: efiStore)
    c.bootLoader = boot

    // 图形 (macOS 14+)
    let gpu = VZVirtioGraphicsDeviceConfiguration()
    gpu.scanouts = [
        VZVirtioGraphicsScanoutConfiguration(
            widthInPixels: displayWidth,
            heightInPixels: displayHeight
        )
    ]
    c.graphicsDevices = [gpu]

    // 输入
    c.keyboards = [VZUSBKeyboardConfiguration()]
    c.pointingDevices = [VZUSBScreenCoordinatePointingDeviceConfiguration()]

    // NAT 网络
    let net = VZVirtioNetworkDeviceConfiguration()
    net.attachment = VZNATNetworkDeviceAttachment()
    c.networkDevices = [net]

    // 音频：添加基础声音支持 (可选)
    let audioOutput = VZVirtioSoundDeviceOutputStreamConfiguration()
    audioOutput.sink = VZHostAudioOutputStreamSink()
    let audioDevice = VZVirtioSoundDeviceConfiguration()
    audioDevice.streams = [audioOutput]
    c.audioDevices = [audioDevice]

    // 杂项
    c.entropyDevices = [VZVirtioEntropyDeviceConfiguration()]
    // c.memoryBalloonDevices = [VZVirtioTraditionalMemoryBalloonDeviceConfiguration()]

    // 存储
    var disks: [VZStorageDeviceConfiguration] = []

    if installMode {
        let winISO = try VZDiskImageStorageDeviceAttachment(url: windowsISO, readOnly: true)
        disks.append(VZUSBMassStorageDeviceConfiguration(attachment: winISO))

        let drvISO = try VZDiskImageStorageDeviceAttachment(url: virtioISO, readOnly: true)
        disks.append(VZUSBMassStorageDeviceConfiguration(attachment: drvISO))
    }

    let sys = try VZDiskImageStorageDeviceAttachment(
        url: diskImage,
        readOnly: false,
        cachingMode: .cached,
        synchronizationMode: VZDiskImageSynchronizationMode.none
    )
    disks.append(VZVirtioBlockDeviceConfiguration(attachment: sys))

    c.storageDevices = disks

    try c.validate()
    return c
}

final class AppDelegate: NSObject, NSApplicationDelegate, VZVirtualMachineDelegate {
    var window: NSWindow!
    var vm: VZVirtualMachine!

    func applicationDidFinishLaunching(_ n: Notification) {
        do {
            let config = try makeConfig()
            let view = VZVirtualMachineView()
            view.capturesSystemKeys = true

            window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: displayWidth, height: displayHeight),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered, defer: false)
            window.center()
            window.title = installMode ? "Windows 11 [Install]" : "Windows 11"
            window.contentView = view
            window.makeKeyAndOrderFront(nil)
            // NSApp.activate(ignoringOtherApps: true)
            NSApp.activate()

            vm = VZVirtualMachine(configuration: config)
            vm.delegate = self
            view.virtualMachine = vm

            vm.start { r in
                if case .failure(let e) = r {
                    print("Start failed: \(e)")
                    NSApp.terminate(nil)
                }
            }
        } catch {
            print("Config error: \(error)")
            NSApp.terminate(nil)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool { true }
    func guestDidStop(_: VZVirtualMachine) { NSApp.terminate(nil) }
    func virtualMachine(_: VZVirtualMachine, didStopWithError e: Error) {
        print("VM crash/error: \(e)")
        NSApp.terminate(nil)
    }
}

let app = NSApplication.shared
let d = AppDelegate()
app.setActivationPolicy(.regular)
app.delegate = d
app.run()
```
