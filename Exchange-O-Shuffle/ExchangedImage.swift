//
//  ExchangedImage.swift
//  Exchange-O-Shuffle
//
//  Created by jacob stimes  & ian mcdowell  on 1/18/16.
//  Copyright © 2016 stimes.enterprises. All rights reserved.
//

import ObjectMapper
import UIKit


class ExchangedImage: Mappable {
    
    //These should reflect the fields tracked on the server for uploaded images
    //Add fields here as they are added to the server if desired
    var url: String!
    var caption: String!
    var author: String!
    var id: String!
    var date: NSDate!
    
    init(url: String, caption: String, author: String){
        self.url = url
        self.caption = caption
        self.author = author
    }
    
    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map){
        url  <- map["url"]
        caption <- map["caption"]
        author <- map["author"]
        id <- map["id"]
        
    }
}