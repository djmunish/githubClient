//
//  LoginWebVC.swift
//  gitTest
//
//  Created by Ankur Sehdev on 04/02/20.
//  Copyright © 2020 Munish. All rights reserved.
//

import UIKit
import WebKit

class LoginWebVC: UIViewController {
    @IBOutlet weak var loader: UIActivityIndicatorView!

    private var completion: ((String) -> Void)! = nil
    private var error: ((Error) -> Void)! = nil
    
    @IBOutlet weak var webView: WKWebView!
    
    private var clientID: String = "d71341109421025bd264"
    private var clientSecret: String = "d2230655b704753771cb7920826e902072f043d9"
    private let redirectURL: String = "https://github.com/"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = self.buildURL(with: [Scopes.repo], allowSignup: true)
        self.webView.load(URLRequest(url: url))
        webView.navigationDelegate = self
//        view.addSubview(webView)
        // Do any additional setup after loading the view.
    }
    
    func login(completion: @escaping (String) -> Void, error: @escaping (Error) -> Void) {
        self.completion = completion
        self.error = error
    }
    
    
    private func buildURL(with scopes : [Scopes], allowSignup: Bool) -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "github.com"
        urlComponents.path = "/login/oauth/authorize"
        let scopeStrings = scopes.map { $0.rawValue }
        let scopesQueryItem = URLQueryItem(name: "scope", value: scopeStrings.joined(separator: " "))
        let redirectURIQueryItem = URLQueryItem(name: "redirect_uri", value: "\(redirectURL)")
        let allowSignupQueryItem = URLQueryItem(name: "allow_signup", value: "\(allowSignup ? "true" : "false")")
        let clientIDQueryItem = URLQueryItem(name: "client_id", value: clientID)
        urlComponents.queryItems = [scopesQueryItem, redirectURIQueryItem, allowSignupQueryItem, clientIDQueryItem]
        return urlComponents.url!
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
//MARK: - WebView Delegates
extension LoginWebVC: WKNavigationDelegate {
 
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.dismiss(animated: true)
        loader.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loader.stopAnimating()
        guard let urlString = webView.url?.absoluteString else { return }
        guard let urlComponents = URLComponents(string: urlString) else { return }
        
        guard let host = urlComponents.host, let scheme = urlComponents.scheme else { return }
        
        let path = urlComponents.path
        let url = scheme + "://" + host + path
        guard url == self.redirectURL else { return }
        
        guard let queryItem = urlComponents.queryItems?.first(where: { $0.name == "code" }) else { return }
        
        guard let code = queryItem.value else { return }
        
        GithubAPI.gitClient.getAccessToken(clientID: clientID, clientSecret: clientSecret, code: code, redirectURL: redirectURL) { [weak self] (response, error) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let response = response {
                    self.completion(response.accessToken)
                } else {
                    self.error(error ?? NSError(domain: "Unknown error", code: 9999, userInfo: nil))
                }
                self.dismiss(animated: true)
            }
        }
    }
}
