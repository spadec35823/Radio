//
//  File.swift
//  TestRadio
//
//  Created by user on 2019/12/5.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import Alamofire
protocol HttpProtocol {
    func didRecieveResults(resultes:NSDictionary)
}

class HttpController: NSObject {
    var delegate: HttpProtocol?
    
    func GetGttp(url:String){
        
        Alamofire.request(url).responseJSON { (resonpse) in
            if resonpse.result.isSuccess {
                if let songResult = resonpse.result.value as? [String: Any]{
                    self.delegate?.didRecieveResults(resultes: songResult as NSDictionary)
                    print("資料？？：\(songResult)")
                }
            }else{
                print("error!!")
            }
        }
        
    }
}

