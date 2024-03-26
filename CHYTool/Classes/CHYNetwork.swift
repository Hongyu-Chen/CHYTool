//
//  CHYNetwork.swift
//  CHYTool
//
//  Created by TAL on 2024/3/21.
//

import Foundation
import SystemConfiguration


public enum CHYNetworkState {
    case WIFI//wifi
    case WWAN//蜂窝数据
    case CONNENT//已连接网络（可能是WI-FI或者WWAN）
    case NONETWORK//无网络
}

public protocol CHYNetworkProtocol:AnyObject{
    func networkStatusChanged(network state:CHYNetworkState)
}


public struct CHYNetworkObserverModel:Equatable {
    public static func == (lhs: CHYNetworkObserverModel, rhs: CHYNetworkObserverModel) -> Bool {
        return lhs.indentifiter == rhs.indentifiter
    }
    let indentifiter:String
    weak var observerObject:CHYNetworkProtocol?
    public init(indentifiter: String, observerObject: CHYNetworkProtocol? = nil) {
        self.indentifiter = indentifiter
        self.observerObject = observerObject
    }
}

public class CHYNetwork:NSObject {
    
    private var protocolList:[CHYNetworkObserverModel] = []
    private var reachability: SCNetworkReachability!
    private var reachabilityNotifier: DispatchSourceTimer!
    private var currentNetworkState:CHYNetworkState = .NONETWORK
    
    public override init() {
        super.init()
        var address = sockaddr_in()
        address.sin_len = __uint8_t(MemoryLayout<sockaddr_in>.size)
        address.sin_family = sa_family_t(AF_INET)
        address.sin_port = in_port_t(0)
        address.sin_addr.s_addr = inet_addr("192.168.1.1")
        reachability = withUnsafePointer(to: &address, { result in
            result.withMemoryRebound(to: sockaddr.self, capacity: 1) { pointer in
                SCNetworkReachabilityCreateWithAddress(nil, pointer)
            }
        })
        reachabilityNotifier = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        reachabilityNotifier.schedule(deadline: .now() + .milliseconds(1000), repeating: .milliseconds(1000))
        reachabilityNotifier.setEventHandler { [weak self] in
            self?.updateNetworkStatus()
        }
        reachabilityNotifier.resume()
        
        updateNetworkStatus()
    }
    
    deinit {
        reachabilityNotifier.cancel()
    }
        
    private func updateNetworkStatus() {
        var flags: SCNetworkReachabilityFlags = []
        if SCNetworkReachabilityGetFlags(reachability, &flags) {
            let isReachable = flags.contains(.reachable)
            let isConnectionRequired = flags.contains(.connectionRequired)
            
            if isReachable && isConnectionRequired {
                // 设备可能连接到蜂窝数据网络
                self.currentNetworkState = .CONNENT
                self.notifierChanged()
            } else {
                // 设备没有连接到网络，或者连接到 Wi-Fi
                self.currentNetworkState = .NONETWORK
                self.notifierChanged()
            }
        } else {
            self.currentNetworkState = .NONETWORK
            self.notifierChanged()
        }
    }
    
    public func addToNotifiList(_ object:CHYNetworkObserverModel) {
        var havOb = false
        for item in self.protocolList {
            if item == object{
                havOb = true
                break
            }
        }
        if havOb == false{
            self.protocolList.append(object)
        }
    }
    
    private func notifierChanged(){
        for (index,item) in self.protocolList.enumerated() {
            if item.observerObject == nil {
                self.protocolList.remove(at: index)
                continue
            }
            item.observerObject?.networkStatusChanged(network: self.currentNetworkState)
        }
    }
}
