//
//  ZSBaseViewController.swift
//  ZSide-Swift
//
//  Created by dazhongge on 2016/12/26.
//  Copyright © 2016年 dazhongge. All rights reserved.
//

import UIKit

class ZSBaseViewController: UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        self.view.backgroundColor = .white
        
        self.loadInit()
        self.loadViews()
        self.loadLayout()
        
    }
    
    public func loadInit() {
    
        print("-------------------- start loadInit Method\n\n")
    
    }
    
    public func loadViews() {
    
        print("-------------------- start loadViews Method\n\n")
    
    }
    
    public func loadLayout() {
    
        print("-------------------- start loadLayout Method\n\n")
    
    }

}
