//
//  VideoViewController.swift
//  Buckets: Basketball Data
//
//  Created by Romell Bolton on 3/8/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import UIKit
import WebKit

class VideoViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet var webView: WKWebView!
    
    var game: Game?
    var activityIndicator = UIActivityIndicatorView(style: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRefreshButton()
        defaultsChanged()
        setupActivityIndicator()
        refreshWebpage()
    }
    
    fileprivate func setupRefreshButton() {
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshWebpage))
        self.navigationItem.rightBarButtonItem = refreshButton
    }
    
    func setupActivityIndicator() {
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        self.activityIndicator.color = UIColor.gray
        self.view.addSubview(self.activityIndicator)
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
    
    @objc func defaultsChanged(){
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        if isDarkMode == true {
            updateToDarkTheme()
        } else {
            updateToLightTheme()
        }
    }
    
    func updateToDarkTheme(){
        navigationController?.view.backgroundColor = .black
        navigationController?.navigationBar.barStyle = .black
        self.view.backgroundColor = UIColor.black
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.tabBarController?.tabBar.barTintColor = .black
        self.navigationController?.navigationBar.barTintColor = UIColor.black
    }
    
    func updateToLightTheme() {
        navigationController?.view.backgroundColor = .white
        navigationController?.navigationBar.barStyle = .default
        self.view.backgroundColor = UIColor.white
        
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        self.tabBarController?.tabBar.barTintColor = .white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    @objc fileprivate func refreshWebpage() {
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
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicator.stopAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        defaultsChanged()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.largeTitleDisplayMode = .always
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
        }
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        }
    }
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
}

