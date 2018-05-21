//
//  FxDatePicker.swift
//  Snapgroup
//
//  Created by hosen gaber on 16.5.2018.
//  Copyright © 2018 snapmac. All rights reserved.
//

import Foundation
//
//  FxDatePicker.swift
//
//  Created by Gasim on 1/14/15.
//

import UIKit

protocol FxDatePickerDelegate {
    
    func dateSelected(datePicker: FxDatePicker!, date : NSDate!);
    
}

enum FxDatePickerMode {
    case Date
    case Time
}

class FxDatePicker: UIView, UIPickerViewDelegate, UIPickerViewDataSource, FxDatePickerDelegate {
    
    class Component {
        var calendar : NSCalendar;
        var components : NSDateComponents;
        var pickerItems : [[String]] = [];
        var order : [String: Int] = [:];
        
        init() {
            self.calendar = NSCalendar.currentCalendar();
            self.components = NSDateComponents();
        }
        
        init(calendar : NSCalendar, order : [String : Int]) {
            self.calendar = calendar;
            self.components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: NSDate());
            self.order = order;
        }
        
        func select(values: [Int]) -> [Int] {
            return [];
        }
        
        func toDate() -> NSDate {
            return calendar.dateFromComponents(components)!;
        }
        
        func getPickerItems() -> [[String]] {
            return pickerItems;
        }
        
        func getCurrentIndices() -> [Int] {
            return [];
        }
        
    }
    
    class TimeComponent : Component {
        
        var format : NSString;
        override init(calendar: NSCalendar, order : [String : Int]) {
            format = NSDateFormatter.dateFormatFromTemplate("j", options: 0, locale: calendar.locale)!;
            super.init(calendar: calendar, order: order);
            if(format.containsString("a")) {
                pickerItems = [[String]](count: 3, repeatedValue: []);
                pickerItems[order["hour"]!] = populateHours(true);
                pickerItems[order["ampm"]!] = populateAmPm();
            } else {
                pickerItems = [[String]](count: 2, repeatedValue: []);
                pickerItems[order["hour"]!] = populateHours(false);
            }
            
            pickerItems[order["minute"]!] = populateMinutes();
        }
        
        override func getCurrentIndices() -> [Int] {
            if(format.containsString("a")) {
                var idx = [Int](count: 3, repeatedValue: 0);
                idx[order["hour"]!] = self.getAmPmHour();
                idx[order["minute"]!] = components.minute;
                idx[order["ampm"]!] = self.getAmPm();
                return idx;
            } else {
                var idx = [Int](count: 2, repeatedValue: 0);
                idx[order["hour"]!] = components.hour - 1;
                idx[order["minute"]!] = components.minute;
                return idx;
            }
        }
        
        override func select(values: [Int]) -> [Int] {
            components.minute = values[order["minute"]!];
            components.hour = values[order["hour"]!];
            
            if values.count == 3 {
                components.hour++;
                if values[order["ampm"]!] == 1 {
                    components.hour += 12;
                }
            }
            return [];
        }
        
        func getAmPmHour() -> Int {
            if components.hour == 0 {
                return 11;
            }
            
            if components.hour > 12 {
                return components.hour - 13;
            }
            return components.hour;
        }
        
        func getAmPm() -> Int {
            
            if(self.components.hour >= 12) {
                return 1;
            }
            return 0;
        }
        
        func populateHours(ampm : Bool = true) -> [String] {
            var hours : [String] = [];
            if ampm {
                var i = 1
                for i in 1 ... 12{
                    if i < 10 {
                        hours.append("0\(i)");
                    } else {
                        hours.append("\(i)");
                    }
                }
            } else {
                 var i = 0
                for i in 0 ... 24{
                    if i < 10 {
                        hours.append("0\(i)");
                    } else {
                        hours.append("\(i)");
                    }
                }
            }
            return hours;
        }
        
        func populateMinutes() -> [String] {
            var minutes : [String] = [];
            var i = 0
            for i in 0 ... 60 {
                if i < 10 {
                    minutes.append("0\(i)");
                } else {
                    minutes.append("\(i)");
                }
            }
            return minutes
        }
        
        func populateAmPm() -> [String] {
            return [
                calendar.AMSymbol,
                calendar.PMSymbol
            ];
        }
        
    }
    
    class DateComponent : Component {
        
        override init(calendar: NSCalendar, order : [String : Int]) {
            super.init(calendar: calendar, order: order);
            pickerItems = [[String]](count: 3, repeatedValue: []);
            pickerItems[order["month"]!] = populateMonths();
            pickerItems[order["year"]!] = populateYears();
            pickerItems[order["day"]!] = populateDays();
        }
        
        override func getCurrentIndices() -> [Int] {
            var idx = [Int](count: 3, repeatedValue: 0);
            idx[order["month"]!] = components.month - 1;
            idx[order["day"]!] = components.day - 1;
            idx[order["year"]!] = components.year - 1;
            return idx;
        }
        
        override func select(values : [Int]) -> [Int] {
            components.year = values[order["year"]!] + 1;
            components.day = values[order["day"]!] + 1;
            components.month = values[order["month"]!] + 1;
            var vals = values;
            if !components.isValidDateInCalendar(calendar) {
                let correct = NSDateComponents();
                correct.month = components.month + 1;
                correct.day = 0;
                correct.year = components.year;
                let date = calendar.dateFromComponents(correct)!;
                let correctDay = calendar.component(.Day, fromDate: date);
                vals[order["day"]!] = correctDay - 1;
                components.day = correctDay;
            }
            
            return vals;
        }
        
        func populateDays() -> [String] {
            var days : [String] = [];
            var i = 1
            for i in 1 ... 31 {
                days.append("\(i)");
            }
            return days;
        }
        
        func populateMonths() -> [String] {
            return NSDateFormatter().monthSymbols as [String];
        }
        
        func populateYears() -> [String] {
            var years : [String] = [];
            for var i = 1; i <= 9999; ++i {
                years.append("\(i)");
            }
            return years;
        }
        
    }
    
    private var pickerView : UIPickerView = UIPickerView();
    private var calendar : NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!;
    private var components : [[String]] = [];
    private var types : [String] = [];
    
    private var component : Component = Component();
    
    var delegate : FxDatePickerDelegate!;
    
    var bgColor : UIColor! = nil;
    var font : UIFont = UIFont.systemFontOfSize(UIFont.systemFontSize());
    var selectedFont : UIFont! = nil;
    var selectedTextColor : UIColor! = nil;
    var textColor : UIColor = UIColor.blackColor();
    var mode : FxDatePickerMode = FxDatePickerMode.Date;
    var locale : NSLocale = NSLocale.systemLocale();
    
    func createComponents() {
        
        calendar.locale = self.locale;
        
        switch(mode) {
        case FxDatePickerMode.Date:
            component = DateComponent(calendar: calendar, order: ["month": 0, "day": 1, "year": 2]);
        case FxDatePickerMode.Time:
            component = TimeComponent(calendar: calendar, order: ["hour": 0, "minute": 1, "ampm": 2]);
            
        }
        
        var indices = component.getCurrentIndices();
        var z = 0
        for z in 0 ... indices.count {
            pickerView.selectRow(indices[i], inComponent: i, animated: false)
        }
        
    }
    
    func initialize() {
        pickerView.delegate = self;
        pickerView.dataSource = self;
        self.delegate = self;
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        initialize();
    }
    
    init() {
        let width = UIScreen.mainScreen().bounds.width;
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: 216));
        initialize();
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!;
        let width = UIScreen.mainScreen().bounds.width;
        self.frame = CGRect(x: 0, y: 0, width: width, height: 216);
        initialize();
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect);
        self.addSubview(pickerView);
        if self.bgColor != nil {
            self.backgroundColor = self.bgColor;
        }
        pickerView.backgroundColor = self.backgroundColor;
        createComponents();
    }
    
    func setCurrent(values : [Int]) {
        var i = 0
        for i in 0 ... values.count{
            pickerView.selectRow(values[i], inComponent: i, animated: false)
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return self.component.getPickerItems().count;
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.component.getPickerItems()[component].count;
    }
    
    func getAttributedString(row: Int, inComponent: Int) -> NSAttributedString {
        
        let selectedRow = self.pickerView.selectedRowInComponent(inComponent);
        
        var font : UIFont = self.font;
        var textColor : UIColor = self.textColor
        if selectedRow == row {
            if let selectedTextColor = self.selectedTextColor {
                textColor = selectedTextColor;
            }
            
            if let selectedFont = self.selectedFont {
                font = selectedFont;
            }
        }
        
        let attributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: textColor
        ];
        
        
        return NSAttributedString(string: self.component.getPickerItems()[inComponent][row], attributes: attributes);
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var i = 0
        var values : [Int] = [];
        for i in 0 ... self.component.getPickerItems().count {
            values.append(pickerView.selectedRowInComponent(i));
        }
        var j = 0
        var vals = self.component.select(values);
        for  j in 0 ... vals.count{
            if vals[i] != values[i] {
                pickerView.selectRow(vals[i], inComponent: i, animated: true);
                pickerView.reloadComponent(i);
            }
        }
        
        pickerView.reloadComponent(component);
        
        let date = self.component.toDate();
        
        delegate.dateSelected(self, date: date);
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        var label = view as! UILabel!;
        if label == nil {
            label = UILabel();
            label.backgroundColor = UIColor.clearColor()
            label.textAlignment = NSTextAlignment.Center;
        }
        label.attributedText = self.getAttributedString(row, inComponent: component);
        return label;
    }
    
    
    func dateSelected(datePicker: FxDatePicker!, date: NSDate!) {
        return;
    }
    
}
