//
//  CalculatorBrain.swift
//  MyCalculator1
//
//  Created by Admin on 19.10.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation

class CalculatorBrain {
    private var accumulator = 0.0
    
    private var internalProgram = [AnyObject]()
    
    private var curPriority = Int.max
        
    private var descriptionAccumulator = "0" {
        didSet {
            if pending == nil {
                curPriority = Int.max
            }
        }
    }
    
    
    
    var description: String {
        get {
            if pending == nil {
                return self.descriptionAccumulator
            } else {
                return pending!.descriptionFunction(pending!.descriptionOperand, pending!.descriptionOperand != self.descriptionAccumulator ? self.descriptionAccumulator : "")
            }
        }
    }
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    func setOperand(operand: Double) {
        internalProgram.append(operand as AnyObject)
        descriptionAccumulator = Double(Int(operand)) == operand ? String(Int(operand)) : String(operand)
        accumulator = operand
    }
    
    func setOperand(variable: String) {
        accumulator = variableValues[variable] ?? 0
        descriptionAccumulator = variable
        internalProgram.append(variable as AnyObject)
    }
    
    var variableValues: Dictionary<String, Double> = [ : ] {
        didSet {
            program = internalProgram as CalculatorBrain.PropertyList
        }
    }
    
    private var operations: Dictionary<String, Operations> = [
        "π" : .Constant(M_PI),
        "e" : .Constant(M_E),
        "Rand" : .NullaryOperation(drand48, "rand()"),
        "ln" : .UnaryOperation(log, {(op: String) -> String in return "ln(" + op + ")"}),
        "√" : .UnaryOperation(sqrt, {(op: String) -> String in return "√(" + op + ")"}),
        "³√" : .UnaryOperation({(op: Double) -> Double in return pow(op, 1/3)}, {(op: String) -> String in return "³√(" + op + ")"}),
        "xʸ" : .BinaryOperation(pow, {(op1: String, op2: String) -> String in return op1 + "^" + op2}, 2),
        "ʸ√" : .BinaryOperation({ (op1: Double, op2: Double) -> Double in return pow(op1, 1/op2) }, {(op1: String, op2: String) -> String in return op1 + "^" + "(1/" + op2 + ")"}, 2),
        "cos" : .UnaryOperation(cos, {(op: String) -> String in return "cos(" + op + ")"}),
        "sin" : .UnaryOperation(sin, {(op: String) -> String in return "sin(" + op + ")"}),
        "x²" : .UnaryOperation({ (op: Double) -> Double in return op*op }, {(op: String) -> String in return "(" + op + ")²"}),
        "x³" : .UnaryOperation({ (op: Double) -> Double in return op*op*op }, {(op: String) -> String in return "(" + op + ")³"}),
        "x⁻¹" : .UnaryOperation({ (op: Double) -> Double in return 1/op }, {(op: String) -> String in return "(" + op + ")⁻¹"}),
        "%" : .UnaryOperation({ (op: Double) -> Double in return op/100 }, {(op: String) -> String in return op + "/100"}),
        "tan" : .UnaryOperation(tan, {(op: String) -> String in return "tan(" + op + ")"}),
        "x!" : .UnaryOperation(factorial,{ (op: String) -> String in return "!" + op }),
        "±" : .UnaryOperation({ (op: Double) -> Double in return -op }, {(op: String) -> String in return "±" + op}),
        "×" : .BinaryOperation({ (op1: Double, op2: Double) -> Double in return op1 * op2 }, {(op1: String, op2: String) -> String in return op1 + "×" + op2}, 1),
        "÷" : .BinaryOperation({ (op1: Double, op2: Double) -> Double in return op1 / op2 }, {(op1: String, op2: String) -> String in return op1 + "÷" + op2}, 1),
        "+" : .BinaryOperation({ (op1: Double, op2: Double) -> Double in return op1 + op2 }, {(op1: String, op2: String) -> String in return op1 + "+" + op2}, 0),
        "-" : .BinaryOperation({ (op1: Double, op2: Double) -> Double in return op1 - op2 }, {(op1: String, op2: String) -> String in return op1 + "-" + op2}, 0),
        "=" : .Equal]
    
    private enum Operations {
        case Constant(Double)
        case NullaryOperation(() -> Double, String)
        case BinaryOperation((Double, Double) -> Double, (String, String) -> String, Int)
        case UnaryOperation((Double) -> Double, (String) -> String), Equal
    }
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol as AnyObject)
        if let operation = operations[symbol] {
            switch operation {
            case .NullaryOperation(let function, let descriptionValue): accumulator = function()
                descriptionAccumulator = descriptionValue
            case .Constant(let value): accumulator = value
                descriptionAccumulator = symbol
            case .UnaryOperation(let function, let descriptionFunction): accumulator = function(accumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
            case .BinaryOperation(let function, let descriptionFunction, let priority): executePendingBinaryOperation()
            if curPriority < priority {
                descriptionAccumulator = "(" + descriptionAccumulator + ")"
            }
            curPriority = priority
            pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator, descriptionOperand: descriptionAccumulator, descriptionFunction: descriptionFunction)
            case .Equal: executePendingBinaryOperation()
            }
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand, descriptionAccumulator)
            pending = nil
        }
    }
    
    
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        var descriptionOperand: String
        var descriptionFunction: (String, String) -> String
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram as CalculatorBrain.PropertyList
        }
        set {
            clear()
            if let newProgram = newValue as? [AnyObject] {
                for op in newProgram {
                    if let operand = op as? Double {
                        setOperand(operand: operand)
                    } else if let symbol = op as? String {
                        if operations[symbol] != nil {
                            performOperation(symbol: symbol)
                        } else {
                            setOperand(variable: symbol)
                        }
                    }
                }
            }
        }
    }
    
    func undoLast() {
        guard !internalProgram.isEmpty else {
            clear()
            return
        }
        
        internalProgram.removeLast()
        program = internalProgram as CalculatorBrain.PropertyList
    }
    
    func clear() {
        accumulator = 0.0
        internalProgram.removeAll()
        descriptionAccumulator = " "
        curPriority = Int.max
        pending = nil
    }
    
    var result: Double {
        return accumulator
    }
}

private func factorial(operand: Double) -> Double {
    if operand <= 1.0 {
        return 1.0
    }
    
    return operand * factorial(operand: operand - 1.0)
}








