//
//  LoginViewController.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 2/15/21.
//

import UIKit
import AuthenticationServices

class LoginViewController: UIViewController {

    @IBOutlet weak var connectSpotifyButton: UIButton!
    
    private let client = APIClient(configuration: URLSessionConfiguration.default)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchToken()
    }
    
    
    @IBAction func connectSpotifyButtonTapped(_ sender: Any) {
        
        getSpotifyAccessCode()
        

    }
    
    private func fetchToken() {
        let token = (UserDefaults.standard.string(forKey: "token"))
        
        if token == nil {
            print("NO TOKEN OR TOKEN EXPIRED")
        } else {
            DispatchQueue.main.async {
                self.goToApp()
                print("TOKEN STILL VALID")
            }
        }
    }
    
    
    // MARK: - Get Spotify Access Code
    
    private func getSpotifyAccessCode() {

        let urlRequest = client.getSpotifyAccessCodeURL()
        print(urlRequest)
        let scheme = "auth"
        let session = ASWebAuthenticationSession(url: urlRequest, callbackURLScheme: scheme) { (callbackURL, error) in
            guard error == nil, let callbackURL = callbackURL else { return }

            let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
            guard let requestAccessCode = queryItems?.first(where: { $0.name == "code" })?.value else { return }
            print(" Code \(requestAccessCode)")
            // exchanges access code to get access token and refresh token
            self.client.call(request: .accessCodeToAccessToken(code: requestAccessCode, completion: { (token) in
                switch token {

                case .failure(let error):
                    print("ERROR: ", error)
                case .success(let token):
                    UserDefaults.standard.set(token.accessToken, forKey: "token")
                    UserDefaults.standard.set(token.refreshToken, forKey: "refresh_token")
                    print("SUCCESS")
                    
                    DispatchQueue.main.async {
                        self.goToApp()
                    }
                }
            }))

        }

        session.presentationContextProvider = self
        session.start()

    }
    
    func goToApp() {
        // present app
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainView") as! UITabBarController
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil)
    }
    

}

// MARK: - AuthenticationServices Window
extension LoginViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window ?? ASPresentationAnchor()
        
    }
}
