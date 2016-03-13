//
//  ImageManager.swift
//  IFlicks
//
//  Created by phuong le on 3/13/16.
//  Copyright © 2016 coderschool.vn. All rights reserved.
//

import Foundation
import SystemConfiguration


class DataNetworkManager {
    enum ImageResolution:Int{
        case low = 92
        case med = 154
        case high = 500
    }
    
    static let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    static let apiPath = "https://api.themoviedb.org/3/movie/"
    
    static let posterBasePath = "https://image.tmdb.org/t/p/w"
    
    static func genGetApiUrl(endPoint:String) -> String {
        return "\(apiPath)\(endPoint)?api_key=\(apiKey)"
    }
    
    static func getPosterUrl(width:Int, subfixUrl:String) -> String {
        return "\(posterBasePath)\(width)\(subfixUrl)"
    }
    
    
    static func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
}