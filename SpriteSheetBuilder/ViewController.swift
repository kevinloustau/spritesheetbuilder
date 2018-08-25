//
//  ViewController.swift
//  SpriteSheetBuilder
//
//  Created by kl on 24/08/2018.
//  Copyright © 2018 kl. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    var myImages: [NSImage] = [NSImage]()
    var finalImage: NSImage = NSImage()
    
    @IBOutlet weak var statusTextLoadImages: NSTextField!
    @IBOutlet weak var statusTextExport: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initApp()
    }
    
    
    
    //MARK: Core functions
    
    func generateSpriteSheet(images: [NSImage]) -> NSImage {
        
        let width = images[0].size.width
        let height = images[0].size.width
        let imageHeight = images[0].size.height * CGFloat(images.count)
        
        let finalSpriteSheet = NSImage(size: CGSize(width: width, height: imageHeight))
        finalSpriteSheet.lockFocus()
        for (index,image) in images.enumerated() {
            let rect = CGRect(x: 0, y: height * CGFloat(index), width: width, height: height)
            image.draw(in: rect)
        }
        finalSpriteSheet.unlockFocus()
        
        return finalSpriteSheet
    }
    
    func generateImage(){
        if myImages.count != 0 {
            finalImage = generateSpriteSheet(images: myImages)
            print("generated!")
        } else {
            print("the images array is empty")
        }
    }
    
    
    
    //MARK: IBAction
    
    @IBAction func loadImages(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["png"]
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = true
        
        panel.begin { [unowned self] result in
            if result == .OK {
                let imageURLs = panel.urls
                for imageURL in imageURLs {
                    self.myImages.append(NSImage(contentsOf: imageURL)!)
                    print(imageURL)
                }
                self.textConfiguration(textField: self.statusTextLoadImages, status: processStatusEnum.success)
            }
        }
    }
    
    
    @IBAction func export(_ sender: Any) {
        
        generateImage()
        
        guard let tiffData = finalImage.tiffRepresentation else { return }
        guard let imageRep = NSBitmapImageRep(data: tiffData) else { return }
        guard let png = imageRep.representation(using: .png, properties: [:]) else { return }
        
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["png"]
        
        panel.begin { result in
            if result == .OK {
                guard let url = panel.url else { return }
                
                do {
                    try png.write(to: url)
                } catch {
                    print (error.localizedDescription)
                }
                self.textConfiguration(textField: self.statusTextExport, status: processStatusEnum.success)
            }
            
        }
    }
    
    //MARK: Other stuffs
    enum processStatusEnum {
        case success, failed, nostatus
    }
    
    func textConfiguration(textField: NSTextField, status: processStatusEnum) {
        
        switch status {
        case .success:
            textField.textColor = NSColor.green
            textField.stringValue = "Success! 🤟"
        case .failed:
            textField.textColor = NSColor.red
            textField.stringValue = "Failed. 🙁"
        case .nostatus:
            textField.stringValue = ""
        }
    }
    
    func initApp() {
        textConfiguration(textField: statusTextLoadImages, status: processStatusEnum.nostatus)
        textConfiguration(textField: statusTextExport, status: processStatusEnum.nostatus)
    }
}

