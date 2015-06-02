//
//  ViewController.swift
//  SwiftFTP
//
//  Created by Charles Konkol on 2015-06-02.
//  Copyright (c) 2015 Rock Valley College. All rights reserved.
//

import UIKit
import CoreGraphics

class ViewController: UIViewController {
    
    let filemgr = NSFileManager.defaultManager()
    
    var sendFile : PutController = PutController()
    
    let username = "username"
    let password = "password"

    override func viewDidLoad() {
        super.viewDidLoad()
         removefile()
        updatedate()
        saveData()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func removefile()
    {
        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource("app", ofType: "txt")!
        var data: NSData = NSData(contentsOfFile: path)!
        
        var error: NSError?
        
        if filemgr.removeItemAtPath(path, error: &error) {
            println("Remove successful")
        } else {
            println("Remove failed: \(error!.localizedDescription)")
        }
    }
    
    func updatedate()
    {
        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource("app", ofType: "txt")!
       
        let text = "yes"
        //writing
    
        text.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)

    }

    func saveData(){
        
        var filename = "ftp://website.com/docs/app.txt"
        
        // Converting the messing filename into one that can be used as a URL
        let convertedStringForURL = filename.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let uploadUrl = NSURL(string: convertedStringForURL!)
        
        // Convert your data and set your request's HTTPBody property
        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource("app", ofType: "txt")!
        var data: NSData = NSData(contentsOfFile: path)!
        
        let dataToUpload = data //NSData(data :data.dataUsingEncoding(NSASCIIStringEncoding)!)
        
        // USE THE OBJECTIVE-C VARIABLE
        sendFile.startSend(dataToUpload, withURL: uploadUrl, withUsername: username, andPassword: password)
        
    }
}

