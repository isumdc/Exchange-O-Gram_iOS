//
//  ImageShuffleViewController.swift
//  Exchange-O-Shuffle
//
//  Created by jacob stimes  & ian mcdowell  on 1/18/16.
//  Copyright © 2016 stimes.enterprises. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import ObjectMapper

class ImageShuffleViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var captionLabel: UILabel!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    
    //Stores images to be shown
    var images: [ExchangedImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load initial set of images:
        loadImages()
    }
    
    @IBAction func nextImageClicked() {
        switchImage()
    }

    //MARK: shake gesture
    override func canBecomeFirstResponder() -> Bool {
        return true;
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        self.becomeFirstResponder()
    }
    
    //For shake gesture
    override func viewWillDisappear(animated: Bool) {
        self.resignFirstResponder()
        super.viewWillDisappear(animated)
    }
    
    //For shake gesture
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if (motion == UIEventSubtype.MotionShake) {
            switchImage()
        }
    }
    
    //MARK: Image handling methods:
    func switchImage(){
        
        //Randomly choose one of the loaded images to display next, so order is different each time
        // using the app
        let size = images.count
        if (size == 0){
            return
        }
        let random = arc4random_uniform(UInt32(size))
        
        let eImg = images[Int(random)]
        
        imageView.af_setImageWithURL(NSURL(string: eImg.url, relativeToURL: NSURL(string: Networking.baseUrl)! )!)
        captionLabel.text = eImg.caption
        authorLabel.text = "Photo by: " + eImg.author
    }
    
    //Load data for all images on server. Retrieves the url for an image, not the image itself,
    // so load image only when displaying
    func loadImages() {
        
        Alamofire.request(.GET, Networking.baseUrl + Networking.retrieveEndpoint).responseJSON { (response) -> Void in
            if let posts = response.result.value as? Array<AnyObject> {
                for post in posts {
                    if let img = Mapper<ExchangedImage>().map(post) {
                        self.images.append(img)
                    }
                }
                
                //Set a picture once everything loaded
                self.switchImage()
            }
        }
        
    }

}

