//
//  ZSBaseTableViewCell.swift
//  ZSide-Swift
//
//  Created by dazhongge on 2016/12/28.
//  Copyright © 2016年 dazhongge. All rights reserved.
//

import UIKit

class ZSBaseTableViewCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.loadInit()
        self.loadViews()
        self.loadLayout()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadInit() {
    
    
    }
    
    func loadViews() {
    
    
    }
    
    func loadLayout() {
    
    
    }

}
