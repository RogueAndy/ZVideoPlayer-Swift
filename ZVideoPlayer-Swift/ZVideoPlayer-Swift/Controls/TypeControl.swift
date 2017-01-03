//
//  TypeControl.swift
//  ZVideoPlayer-Swift
//
//  Created by dazhongge on 2017/1/3.
//  Copyright © 2017年 dazhongge. All rights reserved.
//

import UIKit
import Foundation

enum Direction {

    case North
    case South(str: String)
    case East(str: String, arr: Array<Any>)
    case West
    
    var excited: String {
    
        switch self {
        case .North:
            return "North"
        case .South(str: "ddd"):
            return "South"
        case .East(let str, let arr):
            let str1 = str
            let arr1 = arr
            print(str1)
            print(arr1)
            return "East"
        case .West:
            return "West"
        default:
            break
        }
        
        return "ddd"
    
    }
    
    func selectDirection() -> String {
    
        switch self {
        case .North:
            return "North"
        case .South(str: "ddd"):
            return "South"
        case .East(let str, let arr):
            let str1 = str
            let arr1 = arr
            print(str1)
            print(arr1)
            return "East"
        case .West:
            return "West"
        default:
            break
        }
        
        return ""
    
    }

}

class TypeControl: NSObject {

    class func direction(type: Direction) -> String {
        
        let str = Direction.East(str: "what", arr: ["11", ["22"]]).selectDirection()
        print(str)
        
        return "哈哈"
    
    }
    
}
