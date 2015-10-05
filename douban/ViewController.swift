//
//  ViewController.swift
//  douban
//
//  Created by shen on 15/9/26.
//  Copyright © 2015年 shen. All rights reserved.
//

import UIKit
import SwiftyJSON
import AlamofireImage
import Alamofire
import MediaPlayer
import AVKit

class ViewController: UIViewController , UITableViewDataSource,UITableViewDelegate,IChannelChoseListener {

    @IBOutlet weak var myImageView: CustomImageView!
    
    @IBOutlet weak var bg: UIImageView!
    
    @IBOutlet weak var tableview: UITableView!
    
    var channel_id:String = "0"
    
    @IBOutlet weak var timeLabel: UILabel!
    
    var timer:NSTimer?
    
    var songs:[JSON] = []
    
    let audioPlayer:MPMoviePlayerController = MPMoviePlayerController()
    
    //初始化
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        myImageView.onRotaion()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame.size = CGSize(width: view.frame.width+20, height: view.frame.height)
        bg.addSubview(blurView)
        
        tableview.dataSource = self
        tableview.delegate = self
        
        tableview.backgroundColor = UIColor.clearColor()
        
                //myHttp.onSearch("https://www.douban.com/j/app/radio/channels")
        //myHttp.onSearch("https://douban.fm/j/mine/playlist?type=n&channel=0&fromsite")
    }
    
    override func viewWillAppear(animated: Bool) {
        print("123")
    }
    
    //播放音乐
    func playMusic(url:String){
        
        self.audioPlayer.stop()
        
        self.audioPlayer.contentURL = NSURL(string: url)
        self.audioPlayer.play()
        
        timer?.invalidate()
        timeLabel.text = "00:00"
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateTime", userInfo: nil, repeats: true)
    }
    
    func updateTime(){
        let c = self.audioPlayer.currentPlaybackTime
        if c > 0 {
            let time = Int(c)
            let sec = time % 60
            let min = time / 60
            
            var str = ""
            
            if min < 10{
                str = "0\(min):"
            }else{
                str = "\(min):"
            }
            
            if sec < 10 {
                str += "0\(sec)"
            }else{
                str += "\(sec)"
            }
            
            self.timeLabel.text = str
        }

    }
    
    //页面加载完成后，访问网络数据
    override func viewDidAppear(animated: Bool) {
        Alamofire.request(Method.GET, "https://douban.fm/j/mine/playlist?type=n&channel=\(channel_id)&fromsite").responseJSON{
            res in
            
            let myJson = JSON(res.2.value!)
            
            print("JSON\(myJson)")
            
            if let tempSong = myJson["song"].array{
                self.songs = tempSong
            }
            
            self.tableview.reloadData()
            
            self.onSelfItemClick(0)
        }

    }
    
    //tableview行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    //tableview设置数据
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCellWithIdentifier("douban", forIndexPath: indexPath) as UITableViewCell
        cell.backgroundColor = UIColor.clearColor()
        let rowData = songs[indexPath.row]
        
        cell.textLabel?.text = rowData["title"].string
        cell.detailTextLabel?.text = rowData["artist"].string
        
        let img = rowData["picture"].string
        
        Alamofire.request(Method.GET, img!).responseImage{
            res in
            cell.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
            cell.imageView?.image = res.2.value!
        }
        return cell
    }
    
    //频道列表点击回调
    func onItemClick(channel_id:String){
        self.channel_id = channel_id
        self.viewDidAppear(true)
    }
    
    //跳转页面时设置监听
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let channelController = segue.destinationViewController as! Channel
        channelController.listener = self
    }
    
    //歌曲列表点击
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        onSelfItemClick(indexPath.row)
    }
    
    func onSelfItemClick(position:Int){
        let indexPath = NSIndexPath(forRow: position, inSection: 0)
        tableview.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
        let picture = songs[position]["picture"].string
        setImage(picture!)
        
        playMusic(songs[position]["url"].string!)
    }
    
    func setImage(url:String){
        Alamofire.request(Method.GET, url).responseImage{
            res in
            self.myImageView.image = res.2.value
            self.bg.image = res.2.value
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

