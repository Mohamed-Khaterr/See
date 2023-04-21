//
//  InternetConnection.swift
//  See
//
//  Created by Khater on 11/18/22.
//

import UIKit
import Network


class InternetConnection{
    static let shared = InternetConnection()
    private var monitor = NWPathMonitor()
    
    private init() {}
    
    public func monitoringConnection(to vc: UIViewController) {
        var alert: UIAlertController?
        
        monitor.pathUpdateHandler = { path in
            if path.status != .satisfied {
                // is not Connected
                DispatchQueue.main.async {
                    alert = UIAlertController(title: "Internet Connection", message: "No connection with internet, Please check for connection.", preferredStyle: .alert)
                    alert?.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
                    
                    if let alert = alert {
                        vc.present(alert, animated: true, completion: nil)
                    }
                }
            } else {
                // is Connected
                DispatchQueue.main.async {
                    alert?.dismiss(animated: true, completion: nil)
                    alert = nil
                }
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
}
