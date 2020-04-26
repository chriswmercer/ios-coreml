//
//  ViewController.swift
//  VisionAppDev
//
//  Created by Chris Mercer on 25/04/2020.
//  Copyright © 2020 Chris Mercer. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, UIGestureRecognizerDelegate, AVSpeechSynthesizerDelegate {
    
    @IBOutlet weak var capturedItemNameLabel: UILabel!
    @IBOutlet weak var capturedItemConfidenceLabel: UILabel!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var flashToggleButton: RoundedShadowButton!
    @IBOutlet weak var capturedImageView: RoundedShadowImageView!
        
    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var speechSynthasizer: AVSpeechSynthesizer!
    
    var photoData: Data?
    var flashOn: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer.frame = cameraView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        speechSynthasizer = AVSpeechSynthesizer()
        speechSynthasizer.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCameraView))
        tap.numberOfTapsRequired = 1
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera!)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            cameraOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddOutput(cameraOutput) {
                captureSession.addOutput(cameraOutput!)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                previewLayer.connection?.videoOrientation = .portrait
                
                cameraView.layer.addSublayer(previewLayer!)
                cameraView.addGestureRecognizer(tap)
                captureSession.startRunning()
            }
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    @objc func didTapCameraView() {
        let settings = AVCapturePhotoSettings()
        settings.previewPhotoFormat = settings.embeddedThumbnailPhotoFormat
        if flashOn { settings.flashMode = .on } else { settings.flashMode = .off}
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func didPressFlash(_ sender: Any) {
        flashOn = !flashOn
        flashToggleButton.setTitle("Flash " + (flashOn ? "On" : "Off"), for: .normal)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            debugPrint(error)
        } else {
            photoData = photo.fileDataRepresentation()
            
            do {
                let model = try VNCoreMLModel(for: SqueezeNet().model)
                let request = VNCoreMLRequest(model: model, completionHandler: results)
                let handler = VNImageRequestHandler(data: photoData!)
                try handler.perform([request])
            } catch {
                debugPrint(error.localizedDescription)
            }
            
            let image = UIImage(data: photoData!)
            capturedImageView.image = image
        }
    }
    
    private func results(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation] else { return }
        
        var topObservation = VNClassificationObservation()
        var firstRun = true
        
        for classification in results {
            if (firstRun) {
                topObservation = classification
                firstRun = false
                continue
            }
            
            let currentConfidence = Int(classification.confidence * 100)
            let topConfidence = Int(topObservation.confidence * 100)
            if currentConfidence > topConfidence {
                topObservation = classification
            }
        }
        
        if topObservation.confidence < 0.1 {
            self.capturedItemNameLabel.text = "I'm not sure, try again."
            self.capturedItemConfidenceLabel.isHidden = true
            speak(fromString: "I'm not sure, please try again")
        } else {
            self.capturedItemNameLabel.text = topObservation.identifier
            let confidenceString = "\(Int(topObservation.confidence * 100))%"
            self.capturedItemConfidenceLabel.text = "Confidence: " + confidenceString
            self.capturedItemConfidenceLabel.isHidden = false
            speak(fromString: "I think that is a \(topObservation.identifier) with a confidence of \(confidenceString)")
        }
    }
    
    func speak(fromString string: String) {
        let speaker = AVSpeechUtterance(string: string)
        speechSynthasizer.speak(speaker)
    }
}

