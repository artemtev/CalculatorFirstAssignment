//
//  ViewController.swift
//  MyCalculator1
//
//  Created by Admin on 19.10.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import UIKit


class CalculatorViewController: UIViewController, UISplitViewControllerDelegate {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var graph: UIButton! {
        didSet{
            graph.isEnabled = false
        }
    }
    
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var userIsTyping = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let buttonTitle = sender.currentTitle!
        
        if userIsTyping {
            let textCurrentInDisplay = display.text!
            if display.text == "0"  {
                display.text = buttonTitle
                return
            }
            
            display.text = textCurrentInDisplay + buttonTitle
        } else {
            display.text = buttonTitle
        }
        userIsTyping = true
    }
    
    var userTypedDot = false
    
    @IBAction func dotButton() {
        if userTypedDot == false {
            display.text! += "."
            userTypedDot = true
            userIsTyping = true
        }
    }
    
    private var displayValue: Double? {
        get {
            if let text = display.text, let value = Double(text) {
                return value
            }
            return nil
        }
        set {
            graph.isEnabled = !brain.isPartialResult
            if let value = newValue {
                display.text = Double(Int(value)) == value ? String(Int(value)) : String(value)
                descriptionLabel.text = brain.description + (brain.isPartialResult ? " ..." : "=")
            } else {
                display.text = "0"
                descriptionLabel.text = " "
                userIsTyping = false
            }
        }
    }    
    
    
    @IBAction func cleadAll(_ sender: UIButton) {
        brain.clear()
        displayValue = nil
        brain.variableValues = [ : ]
    }
    var savedProgram: CalculatorBrain.PropertyList?
    
    @IBAction func saveButton() {
        savedProgram = brain.program
    }
    
    @IBAction func restoreButton() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    
    fileprivate let defaults = UserDefaults.standard
    
    typealias PropertyList = AnyObject
    
    fileprivate var program: PropertyList? {
        get { return defaults.object(forKey: "CalculatorViewController.Program") as CalculatorViewController.PropertyList? }
        set { defaults.set(newValue, forKey: "CalculatorViewController.Program") }
    }

    
    private var savedProgramForBackspace: CalculatorBrain.PropertyList?
    
    @IBAction func backspace(_ sender: UIButton) {
        if userIsTyping {
            display.text!.remove(at: display.text!.characters.index(before: display.text!.endIndex))
            if display.text!.isEmpty {
                userIsTyping = false
                displayValue = brain.result
            }
        } else {
            brain.undoLast()
            displayValue = brain.result
        }
    }
    
    
    private var brain = CalculatorBrain()

    @IBAction func performOperation(_ sender: UIButton) {
        if userIsTyping {
            if let value = displayValue{
                brain.setOperand(operand: value)
            }
            userIsTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle{
            brain.performOperation(symbol: mathematicalSymbol)
        }
        displayValue = brain.result
        userTypedDot = false
        descriptionLabel.text = brain.description + (brain.isPartialResult ? " ..." : "=")

    }
    
    
    @IBAction func setX(_ sender: UIButton) {
        userIsTyping = false
        let symbol = String(sender.currentTitle!.characters.dropFirst())
        if let value = displayValue {
            brain.variableValues[symbol] = value
        }
    }
    
    
    @IBAction func showX(_ sender: UIButton) {
        brain.setOperand(variable: sender.currentTitle!)
        displayValue = brain.result
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String,
                                     sender: Any?) -> Bool {
        return !brain.isPartialResult
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let gVC = segue.destination.contentViewController
            as? GraphViewController, segue.identifier == "Show Graph" {
            prepareGraphVC(gVC)
        }
    }
    
    @IBAction func showGraph(_ sender: UIButton) {
        program = brain.program
        if let gVC = splitViewController?.viewControllers.last?.contentViewController
            as? GraphViewController{
            prepareGraphVC(gVC)
        } else {
            performSegue(withIdentifier: "Show Graph", sender: nil)
        }
    }
    
    fileprivate func prepareGraphVC(_ graphVC : GraphViewController){
        graphVC.navigationItem.title = brain.description
        graphVC.yForX = { [ weak weakSelf = self] x in
            weakSelf?.brain.variableValues["X"] = x
            return weakSelf?.brain.result
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !brain.isPartialResult{
            
            program = brain.program
        }
    }
    
    // MARK: - UISplitViewControllerDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.groupTableViewBackground]
        splitViewController?.delegate = self
        
        if let savedProgram = program as? [AnyObject]{
            
            brain.program = savedProgram as CalculatorBrain.PropertyList
            displayValue = brain.result
            if let gVC = splitViewController?.viewControllers.last?.contentViewController
                as? GraphViewController {
                prepareGraphVC(gVC)
            }
        }
        let image = UIImage(named: "graph")
        let tintedImage = image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        graph.setImage(tintedImage, for: .normal)
        graph.tintColor = UIColor.darkGray
        self.navigationItem.hidesBackButton = true
    }

    
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool
    {
        if primaryViewController.contentViewController == self {
            if let gvc = secondaryViewController.contentViewController
                as? GraphViewController, gvc.yForX == nil {
                if program != nil {
                    return false
                }
                return true
            }
        }
        return false
    }


}

extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
}

