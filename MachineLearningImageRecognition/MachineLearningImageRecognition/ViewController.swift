//
//  ViewController.swift
//  MachineLearningImageRecognition
//
//  Created by Berkay Kuzu on 10.09.2022.
//

import UIKit
import CoreML
import Vision // Vision library is used with CoreML especially in image recognition!!!
// By importing two libraries(CoreML and Vision), we can start writing functions!

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Request and Handle!! Two crucial main concepts!!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    var chosenImage = CIImage()
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func changeClicked(_ sender: Any) {
        
        //UIImage'dan fotoğraf seçme işlemi
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        // We convert UIImage to CIImage which means Core Image
        if let ciImage = CIImage(image: imageView.image!) {
            chosenImage = ciImage
        }
        
        recognizeImage(image: chosenImage) // We call recognizeImage() as soon as image is picked!
    }
    
    func recognizeImage (image: CIImage) {
        
        // Image Recognition
        // 1) Request
        // 2) Handler
        
        resultLabel.text =  "Finding..."
         
            if let model = try? VNCoreMLModel(for: MobileNetV2FP16().model) { // Model is defined as a variable.
                let request = VNCoreMLRequest(model: model) { vnrequest, error in
                    
                    if let results = vnrequest.results as? [VNClassificationObservation] {
                        if results.count > 0 { // If there is an image, give me the first one!!!
                            let topResult = results.first
                            
                            DispatchQueue.main.async {
                                var confidenceLevel = (topResult?.confidence ?? 0) * 100
                                
                                confidenceLevel.round(.towardZero)
                                
                                self.resultLabel.text = "\(confidenceLevel)% it's \(topResult!.identifier)"
        
                            }
                        }
                    }
                        
                }
                let handler = VNImageRequestHandler(ciImage: image)
                 DispatchQueue.global(qos: .userInteractive).async {
                     do {
                         try handler.perform([request])
                     } catch {
                         print("error")
                     }
                    
                 }
                
            }
    }

}

