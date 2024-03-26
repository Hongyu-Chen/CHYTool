//
//  ViewController.swift
//  CHYTool
//
//  Created by chenhongyu on 03/21/2024.
//  Copyright (c) 2024 chenhongyu. All rights reserved.
//

import UIKit
import CHYTool

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let dd = CHYNetwork.init()
        dd.addToNotifiList(CHYNetworkObserverModel.init(indentifiter: "", observerObject: self))
//        delegateWindow()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController:CHYNetworkProtocol{
    func networkStatusChanged(network state: CHYTool.CHYNetworkState) {
        
    }
    
    
}

