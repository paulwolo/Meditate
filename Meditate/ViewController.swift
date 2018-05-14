//
//  ViewController.swift
//  Meditate
//
//  Created by Paul Woloszyn on 4/30/18.
//  Copyright © 2018 paulwolo. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, BWWalkthroughViewControllerDelegate {
    
    // BAEEF5 light-blue color
    // RGB: 186 238 245
    // 44 46 58
    // 87% grey scale
    let myGrayBlue = UIColor(displayP3Red: (44.0/255.0), green: (46.0/255.0), blue: (58.0/255.0), alpha: 1.0)
    let myBlue = UIColor(displayP3Red: (186.0/255.0), green: (238.0/255.0), blue: (245.0/255.0), alpha: 1.0)
    
    // sets the intensity of the flashlight
    var torchMode: Float = 0.0
    
    // says whether variable is increasing
    var increasing = true;
    
    @IBOutlet weak var BeginMeditationButton: UIButton!
    
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    @IBAction func beginMeditation(_ sender: UIButton) {
        
        guard let currentButtonName = sender.currentTitle else {
            print("error")
            return
        }
                
        if currentButtonName == "Start" || currentButtonName == "Resume" {
            resetButton.backgroundColor = myBlue
            timeRemainingTimer = Timer.scheduledTimer(timeInterval: timeRemainingDuration, target: self, selector: (#selector(ViewController.updateThirdTimer)), userInfo: nil, repeats: true)
            startTimer()
            sender.setTitle("Pause", for: .normal)
            UIApplication.shared.isIdleTimerDisabled = true
        } else if currentButtonName == "Pause" {
            timeRemainingTimer.invalidate()
            pauseTimer()
            sender.setTitle("Resume", for: .normal)
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    // pauses the timer
    func pauseTimer() {
        timer.invalidate()
        secondTimer.invalidate()
        turnOffTorch()
    }
    
    // resets the timer
    @IBAction func resetTimer(_ sender: UIButton) {
        resetMeditation()
    }
    
    func resetMeditation() {
        resetButton.backgroundColor = myGrayBlue
        BeginMeditationButton.setTitle("Start", for: .normal)
        torchMode = 0.0
        increasing = true
        timer.invalidate()
        secondTimer.invalidate()
        timeRemainingTimer.invalidate()
        timerDisplayValue = 600
        breathsPerMinute = 0.0625
        turnOffTorch()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    // timer to adjust the brightness gradually
    var timer = Timer()
    // timer to adjust the speed at which the brightness adjusts
    var secondTimer = Timer()
    
    var timeRemainingTimer = Timer()
    
    // rate at which the brightness adjusts
    var breathsPerMinute = 0.0625
    
    // rate at which the
    let meditationDuration = 60.0
    
    let timeRemainingDuration = 1.0
    
    // starts the two timers
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: breathsPerMinute, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
        secondTimer = Timer.scheduledTimer(timeInterval: meditationDuration, target: self, selector: (#selector(ViewController.updateSecondTimer)), userInfo: nil, repeats: true)
    }
    
    @IBOutlet weak var timeRemainingDisplay: UILabel!
    
    var timerDisplayValue: Int {
        get {
            let displayText = timeRemainingDisplay.text!
            if displayText.count == 5 {
                let minutes = Int(displayText[0...1])
                let seconds = Int(displayText[3...4])
                return (minutes! * 60) + seconds!
            } else if displayText.count == 4 {
                let minutes = Int(displayText[0..<1])
                let seconds = Int(displayText[2...3])
                return (minutes! * 60) + seconds!
            } else {
                print("error in display")
                return 0
            }
        }
        set {
            let minutes = newValue / 60
            let seconds = newValue % 60
            if seconds < 10 {
                timeRemainingDisplay.text = "\(minutes):0\(seconds)"
            } else {
                timeRemainingDisplay.text = "\(minutes):\(seconds)"
            }
        }
    }
    
    @objc func updateThirdTimer() {
        if timerDisplayValue >= 1 {
            timerDisplayValue -= 1
        } else {
            timeRemainingTimer.invalidate()
            timerDisplayValue = 600
        }
    }
 
    // every 60 seconds, this is executed. Indicates the flashight to decrease the
    // rate at which the brightness adjusts.
    @objc func updateSecondTimer() {
        if breathsPerMinute <= 0.125 {
            timer.invalidate()
            secondTimer.invalidate()
            breathsPerMinute += 0.0078125
            startTimer()
        } else {
            resetMeditation()
        }
    }
    
    // each time this is executed, the brightness adjusts one increment
    @objc func updateTimer() {
        
        if increasing {
            torchMode += 0.025
        } else {
            torchMode -= 0.025
        }
        if torchMode > 1 {
            torchMode = 1
            increasing = false
        } else if torchMode < 0 {
            torchMode = 0
            increasing = true
        }
        updateTorch()
    }
    
    // function to update the flashlight
    func updateTorch() {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
            return
        }
        
        if device.hasTorch && device.isTorchAvailable {
            
            do {
                try device.lockForConfiguration()
                
                if torchMode == 0 {
                    device.torchMode = .off
                } else {
                    try device.setTorchModeOn(level: torchMode)
                }
                
                device.unlockForConfiguration()
                
            } catch {
                print("Torch is not working.")
            }
        } else {
            print("Torch not compatible with device.")
        }
    }
    
    // turns off the torch
    func turnOffTorch() {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
            return
        }
        
        if device.hasTorch && device.isTorchAvailable {
            
            do {
                try device.lockForConfiguration()
                device.torchMode = .off
                device.unlockForConfiguration()
                
            } catch {
                print("Torch is not working.")
            }
        } else {
            print("Torch not compatible with device.")
        }
    }
    
    
    
    @IBAction func walkthroughButtonTouched() {
        let stb = UIStoryboard(name: "Main", bundle: nil)
        let walkthrough = stb.instantiateViewController(withIdentifier: "Master") as! BWWalkthroughViewController
        let page_one = stb.instantiateViewController(withIdentifier: "page1") as UIViewController
        let page_two = stb.instantiateViewController(withIdentifier: "page2") as UIViewController
        let page_three = stb.instantiateViewController(withIdentifier: "page3") as UIViewController
        let page_four = stb.instantiateViewController(withIdentifier: "page4") as UIViewController

        
        // Attach the pages to the master
        walkthrough.delegate = self
        walkthrough.add(viewController:page_one)
        walkthrough.add(viewController:page_two)
        walkthrough.add(viewController:page_three)
        walkthrough.add(viewController:page_four)
        
        
        self.present(walkthrough, animated: true, completion: nil)
    }
    
    func walkthroughCloseButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "Possible Background.jpg")!)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // restricts to portrait mode only
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    

}

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}

