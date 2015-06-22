//
//  PagingViewController.swift
//  WeathFlow
//
//  Created by Nicole Lehrer on 6/22/15.
//  Copyright (c) 2015 Nicole Lehrer. All rights reserved.
//

import UIKit

//http://www.techotopia.com/index.php/An_Example_Swift_iOS_8_UIPageViewController_Application
//programatically creating a paging view controller


class PagingViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource  {

    var pageController:UIPageViewController?
    let numPages = 3
    var allPagesContent = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createContentPages()
        pageController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageController?.delegate = self
        pageController?.dataSource = self
        
        //set start view controller
        let presentViewController = viewControllerAtIndex(1) as ViewController!
        let viewControllers:NSArray = [presentViewController]

        pageController!.setViewControllers(viewControllers as [AnyObject], direction: .Forward, animated: false, completion: nil)
        
        self.addChildViewController(pageController!)
        self.view.addSubview(self.pageController!.view)
        
        var pageViewInRect = self.view.bounds
        pageController!.view.frame = pageViewInRect
        pageController!.didMoveToParentViewController(self)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    

    func createContentPages(){
        
        println("content was created")
        //get data for present - load, past - cache, future - load
        //right now let's make a request each time for present
        
        let tempArray = ["yesterday", "today", "tomorrow"]
        allPagesContent = tempArray
    }
    
    
    
    
    
    
    //helper functions
    func viewControllerAtIndex(index:Int)-> ViewController?{
        if (allPagesContent.count == 0) || (index >= allPagesContent.count){
            return nil
        }
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let dataViewController = storyBoard.instantiateViewControllerWithIdentifier("weatherTable") as! ViewController
        dataViewController.dataObject = allPagesContent[index]
        //dataViewController.view.backgroundColor =  pageColors[index] as? UIColor
        
        return dataViewController
    }
    
    func indexofViewController(viewController:ViewController)->Int{
        if let dataObject:AnyObject = viewController.dataObject{
            return allPagesContent.indexOfObject(dataObject)
        }
        else{
            return NSNotFound
        }
    }


    //data source methods
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?{
        var index = indexofViewController(viewController as! ViewController)
        if (index == 0) || (index == NSNotFound){
            return nil
        }
        index--
        return viewControllerAtIndex(index)
    }
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?{
        
            var index = indexofViewController(viewController as! ViewController)
            if index == NSNotFound{
                return nil
            }
            index++
            if index == allPagesContent.count{
                return nil
            }
            return viewControllerAtIndex(index)
    }

}
