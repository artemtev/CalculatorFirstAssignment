//
//  ContainerViewController.swift
//  MyCalculator1
//
//  Created by Admin on 03.11.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {

    var centerNavigationController: UINavigationController!
    var centerViewController: CalculatorViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // centerViewController = UIStoryboard.centerViewController()
        //centerViewController.delegate = self
        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ContainerViewController: CenterViewControllerDelegate {
    func toggleRightPanel() {
        
    }
    func addRightPanelViewController() {
        
    }
    
    func animatedRightPanel(#shouldExpand: Bool) {
        
    }
}
