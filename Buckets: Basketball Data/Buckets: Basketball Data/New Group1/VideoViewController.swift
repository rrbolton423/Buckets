//
//  ViewController.swift
//  WebViewExample
//
//  Created by wayou on 10/26/18.
//  Copyright © 2018 wayou. All rights reserved.
//
//  references:
//  - https://www.hackingwithswift.com/read/4/2/creating-a-simple-browser-with-wkwebview
//  - https://stackoverflow.com/questions/49638653/load-local-web-files-resources-in-wkwebview


import UIKit
import WebKit

class VideoViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var webView: WKWebView!
    var game: Game?
    var activityIndicator = UIActivityIndicatorView(style: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaultsChanged()
        setupActivityIndicator()
        if CheckInternet.connection() {
                let url = URL.init(string: "https://www.nba.com/games/\(self.game?.gameURL ?? "")#/video")
                self.webView.allowsBackForwardNavigationGestures = true
                let request = URLRequest(url: url!)
                self.webView.load(request)
        } else {
                let alert = UIAlertController(title: "No Internet Connection", message: "Your device is not connected to the internet", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    self.navigationController?.popToRootViewController(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
        }
    }
    
    func setupActivityIndicator() {
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        self.activityIndicator.color = UIColor.gray
        self.view.addSubview(self.activityIndicator)// Auto layout
        let horizontalConstraint = NSLayoutConstraint(item: activityIndicator,
                                                      attribute: .centerX,
                                                      relatedBy: .equal,
                                                      toItem: self.view,
                                                      attribute: .centerX,
                                                      multiplier: 1,
                                                      constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: activityIndicator,
                                                    attribute: .centerY,
                                                    relatedBy: .equal,
                                                    toItem: self.view,
                                                    attribute: .centerY,
                                                    multiplier: 1,
                                                    constant: 0)
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint])
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicator.stopAnimating()
        print("Finished navigating to url \(String(describing: webView.url))")
    }
    
    @objc func defaultsChanged(){
        var isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        if isDarkMode == true {
            //dark theme enabled
            updateToDarkTheme()
            //isDarkMode = true
            print(isDarkMode)
            
        } else {
            
            //dark theme disabled
            updateToLightTheme()
            //isDarkMode = false
            print(isDarkMode)
            
        }
    }
    
    func updateToDarkTheme(){
        self.view.backgroundColor = UIColor.black
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.tabBarController?.tabBar.barTintColor = .black
        self.navigationController?.navigationBar.barTintColor = UIColor.black
    }
    
    func updateToLightTheme() {
        self.view.backgroundColor = UIColor.white
        
    self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        self.tabBarController?.tabBar.barTintColor = .white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        defaultsChanged()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
        }
    }
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

