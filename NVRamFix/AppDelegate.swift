//
//  AppDelegate.swift
//  NVRamFix
//
//  Created by Nattapong Pullkhow on 12/1/2557 BE.
//  Copyright (c) 2557 Nattapong Pullkhow. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
                            

    @IBOutlet var window: NSWindow
    @IBAction func FuosionLoaderIconClick(sender : AnyObject) {
        setConfirm("install", ConfirmTitle_: "Install Fusion NVRam Loader!", ConfirmText_: "Do you want to Install \"Fusion NVRam Loader\" and \"Fix NVRam\"? ",ConfirmIconText_: "Install Loader")
    }
    
    @IBAction func NVRamFixIconClick(sender : AnyObject) {
        setConfirm("fix", ConfirmTitle_: "Fix NVRam!", ConfirmText_: "Do you want to \"Fix NVRam\"? ",ConfirmIconText_: "Fix NVRam")
    }
    @IBAction func SetQUIT(sender : AnyObject) {
        if (self.window.visible) {
            self.window.orderOut(window)
        } else if (self.ConfirmWindow.visible) {
            self.ConfirmWindow.orderOut(ConfirmWindow)
            if (!self.MainWindow.visible) {
                self.MainWindow.orderFront(window)
            }
        } else if (self.MainWindow.visible || self.ResultWindow.visible) {
            NSApplication.sharedApplication().terminate(self)
        }
    }
  
    @IBOutlet var MainWindow : NSPanel
    
    @IBOutlet var ConfirmWindow : NSPanel
    @IBOutlet var ConfirmTitle : NSTextField
    @IBOutlet var ConfirmText : NSTextField
    @IBOutlet var ConfirmIcon : NSButton
    @IBOutlet var ConfirmIconText : NSTextField
    @IBAction func ConfirmIconClick(sender : AnyObject) {
        SetAction()
    }
   
    @IBAction func ConfirmIconCanelClick(sender : AnyObject) {
        ConfirmWindow.orderOut(ConfirmWindow)
        MainWindow.orderFront(MainWindow)
    }
    
    
    @IBOutlet var ResultWindow : NSPanel
    @IBOutlet var ResultTitle : NSTextField
    @IBOutlet var ResultText : NSTextField
    @IBAction func ResultIconCloseClick(sender : AnyObject) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    @IBOutlet var VersionTEXT : NSTextField
    @IBAction func ShowAboutWindow(sender : AnyObject) {
        VersionTEXT.stringValue = "Version \(Version.Main()) build \(Version.Build())"
        self.window.orderFront(window)
    }
    
    
    var NVRamSolution = String()
    var NVRamAction = String()
    
    func setConfirm(NVRamAction_:String,ConfirmTitle_:String,ConfirmText_:String,ConfirmIconText_:String) {
        if(self.MainWindow.visible) { self.MainWindow.orderOut(MainWindow) }
        if(NVRamAction_ == "fix" || NVRamAction_ == "install") {
            NVRamSolution = "\(NVRamAction_)"
            if(!self.ConfirmWindow.visible) {
                ConfirmWindow.orderFront(ConfirmWindow)
                let NVRamIcon = NSImage(named: NVRamAction_)
                ConfirmIcon.image = NVRamIcon
                ConfirmText.stringValue = "\(ConfirmText_)"
                ConfirmTitle.stringValue = "\(ConfirmTitle_)"
                ConfirmIconText.stringValue = "\(ConfirmIconText_)"
            }
        }
    }
    func SetAction() {
        if (isFindMyMacON()) {
            if(NVRamSolution == "install") {
                installFusionLoader()
            } else if(NVRamSolution == "fix") {
                fixNvram()
            }
            if (self.ConfirmWindow.visible) {
                self.ConfirmWindow.orderOut(ConfirmWindow)
            }
        } else {
            setNoFindMyMac()
        }
    }
    func setNoFindMyMac() {
        var Task = NSTask()
        Task.launchPath = "/usr/bin/osascript"
        Task.arguments = [ "-e","tell application \"System Preferences\" to activate"]
        Task.launch()
        ResultText.stringValue = "Your system not Enable \"Find My Mac\".Please,Enable \"Find My Mac\" and try Again Later."
        ResultTitle.stringValue = "Operation Error!"
        if(!ResultWindow.visible) { ResultWindow.orderFront(ResultWindow) }
    }
    func setInstallSuccess() {
        ResultText.stringValue = "Install \"Fusion NVRam Loader\" Success You Need to Restart System to take effect."
        ResultTitle.stringValue = "Operation  Success!"
        if(!ResultWindow.visible) { ResultWindow.orderFront(ResultWindow) }
    }
    func setFixSuccess() {
        ResultText.stringValue = "Fix \"NVRam \" Success You Need to Restart System to take effect."
        ResultTitle.stringValue = "Operation  Success!"
        if(!ResultWindow.visible) { ResultWindow.orderFront(ResultWindow) }
    }
    func setInstallError() {
        ResultText.stringValue = "Install \"Fusion NVRam Loader\" no Success.Please,Try Again Later."
        ResultTitle.stringValue = "Operation Error!"
        if(!ResultWindow.visible) { ResultWindow.orderFront(ResultWindow) }
    }
    func setFixError() {
        ResultText.stringValue = "Fix \"NVRam \" no Success.Please,Try Again Later."
        ResultTitle.stringValue = "Operation Error!"
        if(!ResultWindow.visible) { ResultWindow.orderFront(ResultWindow) }
    }
    func installFusionLoader() {
        let pathToResource: String = NSBundle.mainBundle().resourcePath
        let LaunchDaemonsDIR: String = "/Library/LaunchDaemons/"
        var plistFusionName:String = "com.hackintoshthailand.ifix.fusion.nvram.plist"
        let nvramPath = "/nvram.plist"
        let nvramTMPPath = "/private/tmp/nvram.plist"
        var OSSarg = []
        var RemoveNVRAMPlist = "rm -f \(nvramPath) ; nvram -xp > \(nvramTMPPath) ; cp -r \(nvramTMPPath) \(nvramPath) ; rm -f \(nvramTMPPath) ; chflags hidden \(nvramPath);"
        var RemoveFusionLoader = "rm -f \(LaunchDaemonsDIR)\(plistFusionName);"
        var TMPCMD = "cp -r \(pathToResource)/\(plistFusionName) \(LaunchDaemonsDIR)\(plistFusionName) ; chown root:wheel \(LaunchDaemonsDIR)\(plistFusionName) ; chmod 755 \(LaunchDaemonsDIR)\(plistFusionName) ; launchctl load \(LaunchDaemonsDIR)\(plistFusionName)"
        
        if (isExistsFuisonLoader()) {
            TMPCMD = "\(RemoveFusionLoader)\(TMPCMD)"
        }
        
        if (isExistsNVRAM()) {
            TMPCMD = "\(RemoveNVRAMPlist)\(TMPCMD)"
        }
        
        var Task = NSTask()
        Task.launchPath = "/usr/bin/osascript"
        Task.arguments = [ "-e","do shell script \"\(TMPCMD) && echo Done \" with administrator privileges"]
        let _pipe = NSPipe()
        Task.standardOutput = _pipe
        Task.launch()
        let data = _pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = removeWhiteSpace(NSString(data: data,encoding: NSUTF8StringEncoding))
        if (output.rangeOfString("Done") && isExistsFuisonLoader() && isExistsNVRAM() && isFindMyMacON()) {
            setInstallSuccess()
        } else {
            setInstallError()
        }
    }
    func fixNvram() {
        let nvramPath = "/nvram.plist"
        let nvramTMPPath = "/private/tmp/nvram.plist"
        var OSSarg = []
        var RemoveNVRAMPlist = "rm -f \(nvramPath);"
        var TMPCMD = "nvram -xp > \(nvramTMPPath) ; cp -r \(nvramTMPPath) \(nvramPath) ; rm -f \(nvramTMPPath) ; chflags hidden \(nvramPath)"
        if (isExistsNVRAM()) {
            TMPCMD = "\(RemoveNVRAMPlist)\(TMPCMD)"
        }
        var Task = NSTask()
        Task.launchPath = "/usr/bin/osascript"
        Task.arguments = [ "-e","do shell script \"\(TMPCMD) && echo Done \" with administrator privileges"]
        let _pipe = NSPipe()
        Task.standardOutput = _pipe
        Task.launch()
        let data = _pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = removeWhiteSpace(NSString(data: data,encoding: NSUTF8StringEncoding))
        if (output.rangeOfString("Done") && isExistsNVRAM() && isFindMyMacON()) {
            setFixSuccess()
        } else {
            setFixError()
        }
    }
    
    func isExistsNVRAM()->Bool {
        let nvramPath = "/nvram.plist"
        var FManager = NSFileManager.defaultManager()
        if (FManager.fileExistsAtPath( nvramPath )) {
            return true
        } else {
            return false
        }
    }
    func isExistsFuisonLoader()->Bool {
        var plistFusionFilePath:String = "/Library/LaunchDaemons/com.hackintoshthailand.ifix.fusion.nvram.plist"
        var FManager = NSFileManager.defaultManager()
        if (FManager.fileExistsAtPath( plistFusionFilePath )) {
            return true
        } else {
            return false
        }
    }
    func isFindMyMacON()->Bool {
        var plistFusionName:String = "com.hackintoshthailand.ifix.fusion.nvram.plist"
        var Task = NSTask()
        Task.launchPath = "/usr/sbin/nvram"
        Task.arguments = [ "fmm-mobileme-token-FMM"]
        let _pipe = NSPipe()
        Task.standardOutput = _pipe
        Task.launch()
        let data = _pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = removeWhiteSpace(NSString(data: data,encoding: NSUTF8StringEncoding))
        if (output.rangeOfString("Error")) { return false } else { return true }
    }
    class Version {
        class func Main()->String {
            let version: AnyObject? = NSBundle.mainBundle().infoDictionary["CFBundleShortVersionString"]
            return version as String
        }
        class func Build()->String {
            let build: AnyObject? = NSBundle.mainBundle().infoDictionary["CFBundleVersion"]
            return build as String
        }
    }
    func removeWhiteSpace(string:String)->String {
        let text = string.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).filter({!$0.isEmpty})
        return " ".join(text)
    }
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        // Insert code here to initialize your application
        
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }


}

