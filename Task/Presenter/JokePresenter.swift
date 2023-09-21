//
//  JokePresenter.swift
//  Assignment
//
//  Created by Ankur Verma on 20/09/23.
//

import Foundation
import UIKit

protocol JokePresenterDelegate :  AnyObject {
    func presentJoke(joke : Joke?)
}

typealias presenterDelegate = JokePresenterDelegate & UIViewController

class JokePresenter {
    
    weak var delegate : presenterDelegate?
    weak var timer: Timer?
    
    public func getJoke(){
        
        guard let url = URL(string: "https://geek-jokes.sameerkumar.website/api") else {return}
        
        let task = URLSession.shared.dataTask(with: url) {[weak self] (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error with the response, unexpected status code: \(response.debugDescription)")
                return
            }
            
            if let data = data{
                let joke = String(decoding: data, as: UTF8.self)
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd, yyyy"
                let jokeDate = dateFormatter.string(from: date)
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "hh:mm:ss a"
                let jokeTime = timeFormatter.string(from: date)
                let jokeObj = Joke(joke: joke, jokeDate: jokeDate, jokeTime: jokeTime)
                self?.delegate?.presentJoke(joke: jokeObj)
            }
        }
        task.resume()
    }
    
    public func startTimerAndGetJoke(){
        self.getJoke()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(withTimeInterval:60.0, repeats: true) { [weak self] _ in
                self?.getJoke()
            }
        }
    }
    
    public func stopTimer() {
        timer?.invalidate()
    }
    
     public func updateJokeList(jokesData:[Joke]) -> [Joke]{
         var tempJokes = [Joke]()
         tempJokes = jokesData
         if tempJokes.count > 10{
             tempJokes.remove(at: tempJokes.count - 1)
         }
         return tempJokes
     }
    
    public func setDelegate(delegate : presenterDelegate){
        self.delegate = delegate
    }
}
