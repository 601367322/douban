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

class ViewController: UIViewController , UITableViewDataSource,UITableViewDelegate,IChannelChoseListener {

    @IBOutlet weak var myImageView: CustomImageView!
    
    @IBOutlet weak var bg: UIImageView!
    
    @IBOutlet weak var tableview: UITableView!
    
    var channel_id:String = "0"
    
    var songs:[JSON] = []
    
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
        
                //myHttp.onSearch("https://www.douban.com/j/app/radio/channels")
        //myHttp.onSearch("https://douban.fm/j/mine/playlist?type=n&channel=0&fromsite")
    }
    
    override func viewWillAppear(animated: Bool) {
        print("123")
    }
    
    //页面加载完成后，访问网络数据
    override func viewDidAppear(animated: Bool) {
        Alamofire.request(Method.GET, "https://douban.fm/j/mine/playlist?type=n&channel=\(channel_id)&fromsite").responseJSON{
            res in
            
            let myJson = JSON(data:res.data!)
            
            print("JSON\(myJson)")
            
            if let tempSong = myJson["song"].array{
                self.songs = tempSong
            }
            
            self.tableview.reloadData()
        }

    }
    
    //tableview行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    //tableview设置数据
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCellWithIdentifier("douban", forIndexPath: indexPath) as UITableViewCell
        
        let rowData = songs[indexPath.row]
        
        cell.textLabel?.text = rowData["title"].string
        cell.detailTextLabel?.text = rowData["artist"].string
        
        let img = rowData["picture"].string
        
        Alamofire.request(Method.GET, img!).responseImage{
            res in
            let tempImg = UIImage(data:res.data!)
            cell.imageView?.image = tempImg
        }
        return cell
    }
    
    //频道列表点击回调
    func onItemClick(channel_id:String){
        self.channel_id = channel_id
        self.viewDidAppear(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let channelController = segue.destinationViewController as! Channel
        channelController.listener = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

