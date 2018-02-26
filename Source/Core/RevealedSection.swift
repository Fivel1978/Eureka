//
//  RevealedSection.swift
//
//  Created by Pavel Dvorovenko on 9/29/17.
//

import Foundation

open class RevealedSection<Row: SelectableRowType> : SelectableSection<Row> where Row: BaseRow {
  
  var callbackOnChange: (() -> Void)?
  
  @discardableResult
  public func onChange(_ callback: @escaping (RevealedSection) -> Void) -> RevealedSection {
    callbackOnChange = { [unowned self] in callback(self) }
    return self
  }
  
  public init(tag: String, selectionType: SelectionType, _ initializer: (RevealedSection<Row>) -> Void = { _ in }) {
    super.init( { section in initializer(section as! RevealedSection<Row>) } )
    
    self.selectionType = selectionType
    self.tag = tag
  }
  
  public required init() {
    fatalError("init() has not been implemented")
  }
  
  private var _value: Row.Cell.Value? {
    didSet {
      guard _value != oldValue else { return }
      callbackOnChange?()
      
      guard let form = self.form else { return }
      guard let t = tag else { return }
      form.tagToValues[t] = (value != nil ? value! : NSNull())
      if let rowObservers = form.rowObservers[t]?[.hidden] {
        for rowObserver in rowObservers {
          (rowObserver as? Hidable)?.evaluateHidden()
        }
      }
      if let rowObservers = form.rowObservers[t]?[.disabled] {
        for rowObserver in rowObservers {
          (rowObserver as? Disableable)?.evaluateDisabled()
        }
      }
    }
  }
  
  /// The typed value of this row.
  open var value: Row.Cell.Value? {
    set (newValue) {
      _value = newValue
    }
    get {
      return _value
    }
  }
}
