//
//  WorkoutTypes.swift
//  RISEapp
//
//  Created by Keelyn McNamara on 12/23/22.
//

import Foundation
import HealthKit




public class WorkoutTypes{
    
    let WorkoutNumber: Int
    
    
    init(rawValue: Int) {
        WorkoutNumber = rawValue
    }
    
    func getname() -> String{
        
        var name: String
        
        switch WorkoutNumber{
        case Int(HKWorkoutActivityType.americanFootball.rawValue):
            name = "American Football"
        case Int(HKWorkoutActivityType.archery.rawValue):
            name = "Archery"
        case Int(HKWorkoutActivityType.australianFootball.rawValue):
            name = "Australian Football"
        case Int(HKWorkoutActivityType.badminton.rawValue):
            name = "Badminton"
        case Int(HKWorkoutActivityType.baseball.rawValue):
            name = "Baseball"
        case Int(HKWorkoutActivityType.basketball.rawValue):
            name = "Basketball"
        case Int(HKWorkoutActivityType.bowling.rawValue):
            name = "Bowling"
        case Int(HKWorkoutActivityType.boxing.rawValue):
            name = "Boxing"
        case Int(HKWorkoutActivityType.cardioDance.rawValue):
            name = "Cardio Dance"
        case Int(HKWorkoutActivityType.climbing.rawValue):
            name = "Climbing"
        case Int(HKWorkoutActivityType.crossTraining.rawValue):
            name = "Cross Training"
        case Int(HKWorkoutActivityType.cooldown.rawValue):
            name = "Cool Down"
        case Int(HKWorkoutActivityType.curling.rawValue):
            name = "Curling"
        case Int(HKWorkoutActivityType.coreTraining.rawValue):
            name = "Core Training"
        case Int(HKWorkoutActivityType.crossCountrySkiing.rawValue):
            name = "CrossCountry Skiing"
        case Int(HKWorkoutActivityType.cycling.rawValue):
            name = "Cycling"
        case Int(HKWorkoutActivityType.discSports.rawValue):
            name = "Disc Sports"
        case Int(HKWorkoutActivityType.downhillSkiing.rawValue):
            name = "Downhill Skiing"
        case Int(HKWorkoutActivityType.elliptical.rawValue):
            name = "Elliptical"
        case Int(HKWorkoutActivityType.equestrianSports.rawValue):
            name = "Equestrian Sports"
        case Int(HKWorkoutActivityType.functionalStrengthTraining.rawValue):
            name = "Functional Strength Training"
        case Int(HKWorkoutActivityType.fishing.rawValue):
            name = "Fishing"
        case Int(HKWorkoutActivityType.fencing.rawValue):
            name = "Fencing"
        case Int(HKWorkoutActivityType.flexibility.rawValue):
            name = "Flexibility"
        case Int(HKWorkoutActivityType.fitnessGaming.rawValue):
            name = "Fitness Gaming"
        case Int(HKWorkoutActivityType.golf.rawValue):
            name = "Golf"
        case Int(HKWorkoutActivityType.gymnastics.rawValue):
            name = "Gymnastics"
        case Int(HKWorkoutActivityType.highIntensityIntervalTraining.rawValue):
            name = "High Intensity Interval Training"
        case Int(HKWorkoutActivityType.handball.rawValue):
            name = "Handball"
        case Int(HKWorkoutActivityType.handCycling.rawValue):
            name = "HandCycling"
        case Int(HKWorkoutActivityType.hiking.rawValue):
            name = "Hiking"
        case Int(HKWorkoutActivityType.hockey.rawValue):
            name = "Hockey"
        case Int(HKWorkoutActivityType.hunting.rawValue):
            name = "Hunting"
        case Int(HKWorkoutActivityType.jumpRope.rawValue):
            name = "Jump Rope"
        case Int(HKWorkoutActivityType.kickboxing.rawValue):
            name = "Kick Boxing"
        case Int(HKWorkoutActivityType.lacrosse.rawValue):
            name = "Lacrosse"
        case Int(HKWorkoutActivityType.martialArts.rawValue):
            name = "Martial Arts"
        case Int(HKWorkoutActivityType.mindAndBody.rawValue):
            name = "Mind and Body"
        case Int(HKWorkoutActivityType.mixedCardio.rawValue):
            name = "Mixed Cardio"
        case Int(HKWorkoutActivityType.paddleSports.rawValue):
            name = "Paddle Sports"
        case Int(HKWorkoutActivityType.pickleball.rawValue):
            name = "Pickleball"
        case Int(HKWorkoutActivityType.play.rawValue):
            name = "Play"
        case Int(HKWorkoutActivityType.preparationAndRecovery.rawValue):
            name = "Preparation and Recovery"
        case Int(HKWorkoutActivityType.racquetball.rawValue):
            name = "Racquetball"
        case Int(HKWorkoutActivityType.running.rawValue):
            name = "Running"
        case Int(HKWorkoutActivityType.rowing.rawValue):
            name = "Rowing"
        case Int(HKWorkoutActivityType.rugby.rawValue):
            name = "Rugby"
        case Int(HKWorkoutActivityType.pilates.rawValue):
            name = "Stairs"
        case Int(HKWorkoutActivityType.sailing.rawValue):
            name = "Sailing"
        case Int(HKWorkoutActivityType.soccer.rawValue):
            name = "Soccer"
        case Int(HKWorkoutActivityType.skatingSports.rawValue):
            name = "Skating Sports"
        case Int(HKWorkoutActivityType.snowboarding.rawValue):
            name = "Snow Boarding"
        case Int(HKWorkoutActivityType.swimming.rawValue):
            name = "Swimming"
        case Int(HKWorkoutActivityType.snowSports.rawValue):
            name = "Snow Sports"
        case Int(HKWorkoutActivityType.stepTraining.rawValue):
            name = "Step Training"
        case Int(HKWorkoutActivityType.surfingSports.rawValue):
            name = "Surfing"
        case Int(HKWorkoutActivityType.socialDance.rawValue):
            name = "Social Dance"
        case Int(HKWorkoutActivityType.stairs.rawValue):
            name = "Stairs"
        case Int(HKWorkoutActivityType.stairClimbing.rawValue):
            name = "Stair Climber"
        case Int(HKWorkoutActivityType.swimBikeRun.rawValue):
            name = "Swim Bike Run"
        case Int(HKWorkoutActivityType.softball.rawValue):
            name = "Softball"
        case Int(HKWorkoutActivityType.squash.rawValue):
            name = "Squash"
        case Int(HKWorkoutActivityType.trackAndField.rawValue):
            name = "Track and Field"
        case Int(HKWorkoutActivityType.traditionalStrengthTraining.rawValue):
            name = "Traditional Strength Training"
        case Int(HKWorkoutActivityType.taiChi.rawValue):
            name = "Tai Chi"
        case Int(HKWorkoutActivityType.tennis.rawValue):
            name = "Tennis"
        case Int(HKWorkoutActivityType.tableTennis.rawValue):
            name = "Table Tennis"
        case Int(HKWorkoutActivityType.volleyball.rawValue):
            name = "Volleyball"
        case Int(HKWorkoutActivityType.waterSports.rawValue):
            name = "Water Sports"
        case Int(HKWorkoutActivityType.waterPolo.rawValue):
            name = "Water Polo"
        case Int(HKWorkoutActivityType.waterFitness.rawValue):
            name = "Water Fitness"
        case Int(HKWorkoutActivityType.wheelchairRunPace.rawValue):
            name = "Wheelchair Run"
        case Int(HKWorkoutActivityType.wheelchairWalkPace.rawValue):
            name = "Wheelchair Walk"
        case Int(HKWorkoutActivityType.walking.rawValue):
            name = "Walking"
        case Int(HKWorkoutActivityType.wrestling.rawValue):
            name = "Wrestling"
        case Int(HKWorkoutActivityType.yoga.rawValue):
            name = "Yoga"
        default:
            name = "Other"
        }
        return name
    }
   
    
    
    
    
    
    
    
    
    
    
}
