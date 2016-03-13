//
//  ViewController.swift
//  IFlicks
//
//  Created by phuong le on 3/9/16.
//  Copyright © 2016 coderschool.vn. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class VideoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mvCollectionView: UICollectionView!
  
    
    @IBOutlet weak var networkStatusView: UIView!
    @IBOutlet weak var styleSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var statusNavigationItem: UINavigationItem!
    
    
    var videoDatas:NSArray = []
    var filteredDatas:NSArray = []
    let refreshControl = UIRefreshControl()
    
    var endPoint = ""
    var isListView = true
    
    let itemPerRowInGrid = 2
    var searchActive = false
    
    var searchMovieUISearchBar:UISearchBar = UISearchBar()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        mvCollectionView.delegate = self
        mvCollectionView.dataSource = self
        
    
        refreshControl.addTarget(self, action: "refreshHandler", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        
        networkStatusView.hidden = true
        
        searchMovieUISearchBar.delegate = self
        statusNavigationItem.titleView = searchMovieUISearchBar
        
        
        
        loadData(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshHandler() {
        loadData(false)
    }
    
    @IBAction func changeStyleHander(sender: UISegmentedControl) {
        isListView = !isListView
        
        isListView ? tableView.insertSubview(refreshControl, atIndex: 0) :
        mvCollectionView.insertSubview(refreshControl, atIndex: 0)
        
        refreshUI()
    }
    
    
    func loadData(isFirsLoad:Bool) {

        if !DataNetworkManager.isConnectedToNetwork() {
            
            self.networkStatusView.hidden = false
            return
        }
        
        self.networkStatusView.hidden = true
        
        
        let url = NSURL(string: DataNetworkManager.genGetApiUrl(endPoint))
        
        
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession (
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        if isFirsLoad {
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        }
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error ) in
                
                
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary {
                        
                        
                        self.videoDatas = (responseDictionary["results"]! as? NSArray)!
                        
                       self.refreshUI()
                      
                    }
                }
                
        });
        
        task.resume()

    }
    
    func refreshUI(){
        
        tableView.hidden = !isListView
        mvCollectionView.hidden = isListView
        
        isListView ? tableView.reloadData() : mvCollectionView.reloadData()
        
        
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        refreshControl.endRefreshing()
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  searchActive ? filteredDatas.count : videoDatas.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("VideoTableViewCell", forIndexPath: indexPath) as! TableViewCell

        let movieInfo:NSDictionary = getMovieInfo(indexPath.row)
        
        cell.videoLabel.text = movieInfo["title"] as? String
        cell.overviewLabel.text = movieInfo["overview"] as? String
        
        let url = getPosterUrlResolution((movieInfo["poster_path"] as? String)!)
        load_image(cell.profileImageView, urlString: url)

        let bgView = UIView()
        bgView.backgroundColor = UIColor(red: 1, green: 1, blue: 204/255, alpha: 1)
        cell.selectedBackgroundView = bgView
   
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return (searchActive ? filteredDatas.count : videoDatas.count) / itemPerRowInGrid
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemPerRowInGrid
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("VideoCollectionViewCell", forIndexPath: indexPath) as! MyCollectionViewCell


        let movieInfo:NSDictionary = getMovieInfo(indexPath.section * itemPerRowInGrid + indexPath.row)

        
        cell.videoLabel.text = movieInfo["title"] as? String
        
        let url = getPosterUrlResolution((movieInfo["poster_path"] as? String)!)
        load_image(cell.profileImageView, urlString: url)

        return cell
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        filteredDatas = videoDatas
        searchActive = true;
        searchBar.showsCancelButton = true
        
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.text = "";
        searchBar.endEditing(true)
        refreshUI()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String){
        
        
        if(searchText.characters.count == 0) {
            filteredDatas = []
        } else {
            let resultPredicate = NSPredicate(format: "title contains[c] %@", searchText)
            filteredDatas = videoDatas.filteredArrayUsingPredicate(resultPredicate)

        }
        
        if(filteredDatas.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        
        refreshUI()
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        
        let vc = segue.destinationViewController as! VideoDetailsViewController
        
        
        let indexPath = isListView ? self.tableView.indexPathForCell(sender as! UITableViewCell) : self.mvCollectionView.indexPathForCell(sender as! MyCollectionViewCell)
        
        let index = isListView ? indexPath!.row : indexPath!.section * self.itemPerRowInGrid + indexPath!.row
        
        let vInfo = getMovieInfo(index)
        
        vc.videoData = vInfo
        vc.videoPosterLowResUrl = getPosterUrlResolution(vInfo["poster_path"] as! String, isLow: true)
        vc.videoPosterHighResUrl = getPosterUrlResolution(vInfo["poster_path"] as! String, isLow: false)
    }
    
    
    func getMovieInfo(index:Int) -> NSDictionary {
        
        let moveInfo = searchActive ? filteredDatas[index] : videoDatas[index]
        return moveInfo as! NSDictionary
    }
    
    
    func getPosterUrlResolution(urlSubfix:String, isLow:Bool = true) -> String {
        
        return isLow ? ( isListView ? DataNetworkManager.getPosterUrl(DataNetworkManager.ImageResolution.low.rawValue, subfixUrl: urlSubfix) : DataNetworkManager.getPosterUrl(DataNetworkManager.ImageResolution.med.rawValue, subfixUrl: urlSubfix)) : DataNetworkManager.getPosterUrl(DataNetworkManager.ImageResolution.high.rawValue, subfixUrl: urlSubfix)

    }
    
    
    func load_image(imgView:UIImageView, urlString:String)
    {
        let url = NSURL(string: urlString)
        let nRequestUrl = NSURLRequest(URL: url!)
        
        imgView.setImageWithURLRequest(nRequestUrl, placeholderImage: nil, success: { (imgRequest, imgResponse, img) -> Void in
            
                if imgResponse != nil {
                    imgView.alpha = 0.0
                    imgView.image = img
                   
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        imgView.alpha = 1.0
                    })
                    
                } else {
                    imgView.image = img
                }
            
            }, failure: {(imgRequest, imgResponse, error) -> Void in
                print("ERROR \(error)")
        })
        
    }
    

}

