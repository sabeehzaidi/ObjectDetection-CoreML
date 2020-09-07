//
//  InstructionsViewController.swift
//  ObjectDetection-CoreML
//
//  Created by Sabeeh Zaidi on 9/7/20.
//  Copyright © 2020 tucan9389. All rights reserved.
//

import UIKit

class InstructionsViewController: UIViewController {

    let PROGRESS_VIEW_MAX_VALUE : Float = 10.0 //Constant. Do not change
    let PROGRESS_VIEW_TIME : Float = 3.0 //Progress bar timer. Change as UX requires.
    var currentTime : Float = 3.0
    
    @IBOutlet weak var progressView: UIProgressView!
    var timer = Timer()
    var endProgressBarValue = 0
    var currentProgressBarValue = 10
    var timesRun = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        currentTime = PROGRESS_VIEW_MAX_VALUE
        progressView.setProgress(PROGRESS_VIEW_MAX_VALUE, animated: false)
        
        cmdGo()
    }
    
    func cmdGo()
    {
        // display the first pose
        incrementTimesRun()

        // start the timer
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(setProgressBar), userInfo: nil, repeats: true)
    }

    func incrementTimesRun()
    {
        // do next pose stuff
        timesRun += 1
        print(timesRun)
    }

    @objc func setProgressBar()
    {
        if currentProgressBarValue == endProgressBarValue
        {
            goToNextScreen()
            
            incrementTimesRun()

            // reset the progress counter
            currentProgressBarValue = 10
        }

        // update the display
        // use poseDuration - 1 so that you display 20 steps of the the progress bar, from 0...19
        progressView.progress = Float(currentProgressBarValue) / Float(10)

        // increment the counter
        currentProgressBarValue -= 1
    }
    
    func goToNextScreen()
    {
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
