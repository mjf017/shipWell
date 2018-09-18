//
//  googleMapsView.swift
//  ShipWell
//
//  Created by Matthew Foster on 18/9/18.
//  Copyright © 2018 MatthewFoster. All rights reserved.
//

import UIKit
import WebKit
class googleMapsView: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    
    var lat = String()
    var long = String()
    let latitudeLabel = UILabel()
    let longitudeLabel = UILabel()
    
    var mapInfo: UIView = {
        let mv = UIView()
        
        mv.frame = CGRect(x: -1, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width + 2, height: 70)
        mv.backgroundColor = .white
        mv.layer.borderColor = UIColor.gray.cgColor
        mv.layer.borderWidth = 1
        
        return mv
    }()
    
    var closeButton: UIButton = {
       
            let bB = UIButton()
            
            bB.setTitle("Close", for: .normal)
            bB.addTarget(self, action: #selector(close), for: .touchUpInside)
            bB.backgroundColor = UIColor(red:0.04, green:0.63, blue:0.86, alpha:1.0)
            bB.layer.cornerRadius = 5
            
            return bB
    }()
    
    @objc func close() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func loadView() {
        webView = WKWebView()
        webView.frame = CGRect(x: 0, y: 100, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 100)
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var googleURL = "https://maps.google.com?q="
            googleURL += lat
        googleURL += "," + long
        
        let url = URL(string: googleURL)!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        
        latitudeLabel.text = "Lat: " + lat
        longitudeLabel.text = "Long: " + long
        latitudeLabel.frame = CGRect(x: 10, y: 15, width: mapInfo.frame.width - 100, height: 20)
        longitudeLabel.frame = CGRect(x: 10, y: 36, width: mapInfo.frame.width - 100, height: 20)
        latitudeLabel.textColor = UIColor(red:0.35, green:0.35, blue:0.36, alpha:1.0)
        longitudeLabel.textColor = UIColor(red:0.35, green:0.35, blue:0.36, alpha:1.0)
        
        closeButton.frame = CGRect(x: mapInfo.frame.width - 90, y: 20, width: 80, height: 30)
        
        mapInfo.addSubview(latitudeLabel)
        mapInfo.addSubview(longitudeLabel)
        mapInfo.addSubview(closeButton)
        
        view.addSubview(mapInfo)
        
        UIView.animate(withDuration:0.4, delay: 1.0, options: .allowUserInteraction,
                       animations: {
                        
                        self.mapInfo.frame = CGRect(x: -1, y: UIScreen.main.bounds.size.height - 70, width: UIScreen.main.bounds.size.width + 2, height: 70)
                        
        }, completion: nil )
    }
    

   

}
