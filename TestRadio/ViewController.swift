//
//  ViewController.swift
//  TestRadio
//
//  Created by user on 2019/12/5.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import SDWebImage
import AVKit
import AVFoundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HttpProtocol, ChannelProtocol{
    // 歌曲封面
    @IBOutlet weak var ImageView: UIImageView!
    // 播放進度指示器
    @IBOutlet weak var ProgressView: UIProgressView!
    // 播放時間
    @IBOutlet weak var playTime: UILabel!
    // 歌曲清單
    @IBOutlet weak var TableView: UITableView!
    // 手勢元件
    @IBOutlet var tap: UITapGestureRecognizer!
    
    @IBOutlet weak var btnPlay: UIImageView!
    
    var eHttp:HttpController = HttpController()
    // 接收歌曲陣列
    var tableData:NSArray = NSArray()
    // 接收歌曲清單陣列
    var channelData:NSArray = NSArray()
    
    var audioPlayer:AVPlayer?
    
    var timer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eHttp.delegate = self
        eHttp.GetGttp(url: "http://douban.fm/j/mine/playlist?type=n&channel=1&from=mainsite")
        eHttp.GetGttp(url: "http://douban.fm/j/app/radio/channels")
        // imageView 添加手勢
        ImageView.addGestureRecognizer(tap!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // 實現httpProtocol協定的方法
    func didRecieveResults(resultes: NSDictionary) {
        if (resultes["song"] != nil){
            self.tableData = (resultes["song"] as? NSArray)!
            if (self.tableData.count == 0){
                return
            }
            self.TableView.reloadData()
            let firDict:NSDictionary = self.tableData[0] as! NSDictionary
            let audioUrl:String = firDict["url"] as! String
            OnSetAudio(url: audioUrl)
            let imgURL:String = firDict["picture"] as! String
            OnSetImage(url: imgURL)
        } else if (resultes["channels"] != nil){
            self.channelData = (resultes["channels"] as? NSArray)!
        }
    }
    
    // 實現channelProtocol協定的方法
    func onChangeChannel(channel_id: String) {
        let url:String = "http://douban.fm/j/mine/playlist?type=n&\(channel_id)&from=mainsite"
        eHttp.GetGttp(url: url)
    }
    
    func OnSetAudio(url:String){
        audioPlayer = AVPlayer(url: URL(string: url)!)
        audioPlayer?.play()
        timer?.invalidate()
        playTime.text = "00:00"
        timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(onUpdate), userInfo: nil, repeats: true)
        // 當播放時播放按鈕不需手勢功能
        btnPlay.removeGestureRecognizer(tap!)
        // imageView 需重新添加手勢功能
        ImageView.addGestureRecognizer(tap!)
        btnPlay.isHidden = true
    }
    
    // 更新計時器
    @objc func onUpdate(){
        let audioTime = audioPlayer?.currentTime()
        
        if  CMTimeGetSeconds(audioTime!) > 0.0{
            let totleTime = audioPlayer?.currentItem?.duration
            let p:CGFloat = CGFloat(CMTimeGetSeconds(audioTime!)/CMTimeGetSeconds(totleTime!))
            ProgressView.setProgress(Float(p), animated: true)
            let all:Int = Int(CMTimeGetSeconds(audioTime!))
            let m:Int = all % 60
            let f:Int = Int(all/60)
            var time:String = ""
            if f<10{
                time = "0\(f):"
            } else {
                time = "\(f)"
            }
            if m < 10{
                time += "0\(m)"
            } else {
                time += "\(m)"
            }
            playTime!.text = time
        }
    }
    
    func OnSetImage(url:String) {
        let imgURL:NSURL = NSURL(string:url)!
        self.ImageView.sd_setImage(with:imgURL as URL)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "douban")
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animate(withDuration: 0.25, animations:{cell.layer.transform = CATransform3DMakeScale(1, 1, 1)})
        
        let rowData:NSDictionary = self.tableData[indexPath.row] as! NSDictionary
        // 標題
        cell.textLabel?.text = rowData["title"] as? String
        // 內容
        cell.detailTextLabel?.text = rowData["artist"] as? String
        
        let imgURL:NSURL = NSURL(string:rowData["picture"] as! String)!
//        cell.imageView?.sd_setImage(with: imgURL as URL )
        cell.imageView?.sd_setImage(with: imgURL as URL, placeholderImage: UIImage.init(named: "rbuttonChat0"))
      
        // 回傳ell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowData:NSDictionary = self.tableData[indexPath.row] as! NSDictionary
        OnSetImage(url: rowData["picture"] as! String)
        OnSetAudio(url: rowData["url"] as! String)
    }
    // 視圖切換將channelData資訊帶入
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let channelC:ChannelController = segue.destination as! ChannelController
        channelC.delegate = self
        channelC.channelData = self.channelData
    }
    // 手勢控制 方法
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        if (sender.view == btnPlay) {
            btnPlay.isHidden = true
            audioPlayer?.play()
            // 取消播放按鈕的手勢功能
            btnPlay.removeGestureRecognizer(tap!)
            // imageView添加手勢功能
            ImageView.addGestureRecognizer(tap!)
        } else {
            btnPlay.isHidden = false
            audioPlayer?.pause()
            // 添加播放按鈕的手勢功能
            btnPlay.addGestureRecognizer(tap!)
            // imageView取消手勢功能
            ImageView.removeGestureRecognizer(tap!)
        }
    }
}

