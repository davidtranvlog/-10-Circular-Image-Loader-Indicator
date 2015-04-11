//
//  CustomImageView.swift
//  ImageLoaderIndicator
//
//  Created by Rounak Jain on 24/01/15.
//  Copyright (c) 2015 Rounak Jain. All rights reserved.
//

import UIKit


class CustomImageView: UIImageView
{
  let progressIndicatorView = CircularLoaderView(frame: CGRectZero)
  
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    // add the progress indicator as a subview to the custom image view
    addSubview(self.progressIndicatorView)
    progressIndicatorView.frame = bounds
    // ensure that progressIndicatorView has the same size as the image view
    progressIndicatorView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
    
    let url = NSURL(string: "http://www.raywenderlich.com/wp-content/uploads/2015/02/mac-glasses.jpeg")
    sd_setImageWithURL(url, placeholderImage: nil, options: .CacheMemoryOnly, progress: {
      [weak self]
      (receivedSize, expectedSize) -> Void in
      
      // calculate the progress
      self!.progressIndicatorView.progress = CGFloat(receivedSize)/CGFloat(expectedSize)
      
      }) {
        [weak self]
        (image, error, _, _) -> Void in
        // Reveal image here
        self!.progressIndicatorView.reveal()
    }
  }
  
}



















