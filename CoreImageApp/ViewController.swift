//
//  ViewController.swift
//  CoreImageApp
//
//  Created by Gio on 1/18/18.
//  Copyright © 2018 George Lomsadze. All rights reserved.
//

import UIKit
import CoreImage
import AssetsLibrary

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK:- Variables
    var context:CIContext!
    var filter:CIFilter!
    var beginImage:CIImage!
    var orientation: UIImageOrientation = .up
    // MARK:- IBoutlets
    //new lines were added
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var amountSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileUrl = Bundle.main.url(forResource: "image", withExtension: "png")
        beginImage = CIImage(contentsOf: fileUrl!)
            filter = CIFilter(name: "CISepiaTone")
            filter.setValue(beginImage, forKey: kCIInputImageKey)
            filter.setValue(0.7, forKey: kCIInputIntensityKey)
        
            let outputImage = filter.outputImage
            context = CIContext(options: nil)
            let cgimg = context.createCGImage(outputImage!, from: outputImage!.extent)
//
            let newImage = UIImage(ciImage: (filter?.outputImage)!)
            self.imageView.image = newImage
    }
    // MARK:- IBActions
    @IBAction func amountValueChanged(_ sender: UISlider) {
        DispatchQueue.main.async {
            let sliderValue = sender.value
            self.filter.setValue(sliderValue, forKey: kCIInputIntensityKey)
            let outputImage = self.filter.outputImage!
            if let cgimg = self.context.createCGImage(outputImage, from: outputImage.extent){
                let newImage = UIImage(cgImage: cgimg, scale: 1, orientation: self.orientation)
                self.imageView.image = newImage
            }
        }
        
    }
    
    @IBAction func loadPhotos(_ sender: UIButton) {
        let pickerC = UIImagePickerController()
        pickerC.delegate = self
        self.present(pickerC, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: nil)
        
        let gotImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        orientation = gotImage.imageOrientation
        beginImage = CIImage(image: gotImage)
        filter.setValue(beginImage, forKey: kCIInputImageKey)
        self.amountValueChanged(amountSlider)
    }
    @IBAction func savePressed(_ sender: UIButton) {
        UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)

    }
    
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}

