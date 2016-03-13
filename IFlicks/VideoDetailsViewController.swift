//
//  VideoDetailsViewController.swift
//  IFlicks
//
//  Created by phuong le on 3/10/16.
//  Copyright © 2016 coderschool.vn. All rights reserved.
//

import UIKit
import MBProgressHUD


class VideoDetailsViewController: UIViewController {

    var videoPosterHighResUrl:String = ""
    var videoPosterLowResUrl:String = ""
    var videoData:NSDictionary?
    var videoDetailData:NSDictionary?
    
    @IBOutlet weak var videoPosterImageView: UIImageView!
    
    @IBOutlet weak var contentScrollView: UIScrollView!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var rateLabel: UILabel!
    
    
    @IBOutlet weak var timeLabel: UILabel!
    
    
    @IBOutlet weak var overviewLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       
        self.navigationItem.title = "Details"

        
        if let navigationBar = navigationController?.navigationBar {
            
            navigationBar.tintColor = UIColor(red: 1.0, green: 0.25, blue: 0.25, alpha: 0.8)
            
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
            shadow.shadowOffset = CGSizeMake(2, 2);
            shadow.shadowBlurRadius = 4;
            navigationBar.titleTextAttributes = [
                NSFontAttributeName : UIFont.boldSystemFontOfSize(20),
                NSForegroundColorAttributeName : UIColor(red: 0.5, green: 0.15, blue: 0.15, alpha: 0.8),
                NSShadowAttributeName : shadow
            ]
        }
        
        
        load_image(videoPosterImageView, lowResUrl: videoPosterLowResUrl, highResUrl: videoPosterHighResUrl)
        
        titleLabel.text = videoData!["title"] as? String
        
        dateLabel.text = videoData!["release_date"] as? String
        
        rateLabel.text = "\(Int((videoData!["popularity"] as? Float)!) ?? 0)"
        
        timeLabel.text = ""
        overviewLabel.text = videoData!["overview"] as? String
        
        
        var dSize = overviewLabel.frame.height
        overviewLabel.sizeToFit()
        
        contentScrollView.contentSize = CGSize(width: contentScrollView.frame.width , height: contentScrollView.frame.height)
        
        
        dSize = overviewLabel.frame.height - dSize
        
        let padding:CGFloat = 50
        let newPos = containerView.frame.origin.y - dSize - padding
        containerView.frame.size.height += dSize
        
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.containerView.frame.origin.y = newPos

        })
        
        loadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loadData() {
        
        
        let mvId = videoData!["id"] as! Int;
        let url = NSURL(string: DataNetworkManager.genGetApiUrl(String(mvId)))
        

        let request = NSURLRequest(URL: url!)
        let session = NSURLSession (
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error ) in
                
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary {
                        
                        
                        self.videoDetailData = responseDictionary
                        
                        self.fillMoreData()
                        
                        MBProgressHUD.hideHUDForView(self.view, animated:
                                true)
                    }
                }
                
        });
        
        task.resume()
        
    }
    
    func fillMoreData() {
        timeLabel.text =  "\(videoDetailData!["runtime"] as! Int) mins"
    }

    
    
    func load_image(imgView:UIImageView, lowResUrl:String, highResUrl:String)
    {
        let lowResRequestUrl = NSURLRequest(URL:  NSURL(string: lowResUrl)!)
        let highResRequestUrl = NSURLRequest(URL:  NSURL(string: highResUrl)!)

        
        imgView.setImageWithURLRequest(lowResRequestUrl, placeholderImage: nil, success: { (smallRequestImg, smallResponseImg, smallImg) -> Void in
            
                imgView.alpha = 0.0
                imgView.image = smallImg
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    imgView.alpha = 1.0
                }, completion: {(success) -> Void in
                    
                    imgView.setImageWithURLRequest(highResRequestUrl, placeholderImage: smallImg, success: { (largeRequestImg, largeResponseImg, largeImg) -> Void in
                            imgView.image = largeImg
                        
                        }, failure: { (largeRequestImg, largeResponseImg, error) -> Void in
                            print("ERROR load detail image \(error)")
                    })
            })
                
            
            }, failure: {(imgRequest, imgResponse, error) -> Void in
                ("ERROR \(error)")
        })
        
    }

}
