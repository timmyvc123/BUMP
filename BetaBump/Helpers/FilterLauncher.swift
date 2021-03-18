//
//  FilterLauncher.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 3/18/21.
//

import UIKit

class FilterLauncher: NSObject {
    
    let blackView = UIView()
    
    func showFilters() {
        //show menu
        
        if let window = UIWindow.key {
            blackView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
            
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            window.addSubview(blackView)
            blackView.frame = window.frame
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5) {
                self.blackView.alpha = 1
            }
        }
    }
    
    @objc func handleDismiss() {
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0
        }
    }
    

}
