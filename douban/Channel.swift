//
//  Channel.swift
//  douban
//
//  Created by shen on 15/9/27.
//  Copyright © 2015年 shen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class Channel: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tv: UITableView!
    
    @IBAction func backClick(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    var listener:IChannelChoseListener?
    
    var channels:[JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.alpha = 0.8
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(animated: Bool) {
        Alamofire.request(Method.GET, "https://www.douban.com/j/app/radio/channels").responseJSON{
            res in
            let myJson = JSON(data:res.2.data!)
            if let temp = myJson["channels"].array{
                self.channels = temp
            }
            self.tv.reloadData()
            print(res.2.value)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCellWithIdentifier("douban", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = channels[indexPath.row]["name"].string!
        return cell

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let temp = channels[indexPath.row]
        if temp != nil {
            if (self.listener != nil){
                //var channel_id = temp["channel_id"].intValue
                self.listener!.onItemClick(String(temp["channel_id"]))
            }
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

protocol IChannelChoseListener{
    func onItemClick(channel_id:String)
}
