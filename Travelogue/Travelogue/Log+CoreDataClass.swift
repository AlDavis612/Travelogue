//
//  Log+CoreDataClass.swift
//  Travelogue
//
//  Created by Alex Davis on 12/4/19.
//  Copyright © 2019 Alex Davis. All rights reserved.
//
//

import UIKit
import CoreData

@objc(Log)
public class Log: NSManagedObject {
    var addDate: Date? {
        get {
            return rawAddDate as Date?
        }
        set {
            rawAddDate = newValue
        }
    }
    
    var image: UIImage? {
        get {
            if let imageData = rawImage as Data? {
                return UIImage(data: imageData)
            } else {
                return nil
            }
        }
        set {
            if let image = newValue {
                rawImage = Data(convertImageToNSData(image: image)! as Data)
            }
        }
    }
    
    convenience init?(title: String, body: String?, image: UIImage?) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        guard let managedContext = appDelegate?.persistentContainer.viewContext, !title.isEmpty else {
            return nil
        }
        
        self.init(entity: Log.entity(), insertInto: managedContext)
        self.title = title
        self.body = body
        self.addDate = Date(timeIntervalSinceNow: 0)
        
        if let image = image {
            self.rawImage = Data(convertImageToNSData(image: image)! as Data)
        }
    }
    
    func convertImageToNSData(image: UIImage) -> NSData? {
        return processImage(image: image).pngData() as NSData?
    }
    
    func processImage(image: UIImage) -> UIImage {
        if (image.imageOrientation == .up) {
            return image
        }
        
        UIGraphicsBeginImageContext(image.size)
        
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size), blendMode: .copy, alpha: 1.0)
        let copy = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        guard let unwrappedCopy = copy else {
            return image
        }
        
        return unwrappedCopy
    }
}
