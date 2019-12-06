//
//  ChannelController.swift
//  TestRadio
//
//  Created by user on 2019/12/5.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

// 建立協定的方法
protocol ChannelProtocol {
    func onChangeChannel(channel_id:String)
}
class ChannelController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // 頻道清單
    @IBOutlet weak var tv: UITableView!
    // 遵循channelProtocolㄒ協定的代理
    var delegate:ChannelProtocol?
    
    var channelData:NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tv.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "channel")
        let rowData = self.channelData[indexPath.row] as! NSDictionary
        cell.textLabel?.text = "\(rowData["name"] as! String)"
//        cell.detailTextLabel?.text = "detail:\(indexPath.row)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowData = self.channelData[indexPath.row] as! NSDictionary
        let channel_id:String? = rowData["channel_id"] as! String?
        let channel:String = "channel=\(channel_id ?? "")"
        delegate?.onChangeChannel(channel_id: channel)
        self.dismiss(animated: true, completion: nil)
        print("選擇了\(indexPath.row)行\(channel)")
    }
}
