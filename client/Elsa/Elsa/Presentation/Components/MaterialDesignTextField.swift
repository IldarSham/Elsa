//
//  MaterialDesignTextField.swift
//  Elsa
//
//  Created by Ildar Shamsullin on 14.11.2024.
//

import SwiftUI

public struct MaterialDesignTextField: View {
  
  // MARK: - Types
  
  public enum TextFieldType {
    case standard
    case secure
  }
  
  private struct Constants {
    static let containerHeight: CGFloat = 52.0
    static let textFieldHeight: CGFloat = 22.0
    static let horizontalPadding: CGFloat = 18.0
    static let verticalPadding: CGFloat = 15.0
    static let cornerRadius: CGFloat = 5.0
    
    static let defaultBorderWidth: CGFloat = 1.0
    static let activeBorderWidth: CGFloat = 2.0
    static let errorBorderWidth: CGFloat = 2.0
    
    static let defaultFontSize: CGFloat = 16.0
    static let activeFontSize: CGFloat = 12.0
    static let activeOffset: CGFloat = -25.0
    
    static let defaultColor = Color(red: 121/255, green: 116/255, blue: 126/255)
    static let activeColor = Color(red: 20/255, green: 166/255, blue: 201/255)
    static let errorColor = Color.red
    static let eyeIconColor = Color(red: 73/255, green: 69/255, blue: 79/255)
  }
  
  // MARK: - Properties
  
  private let type: TextFieldType
  private let placeholder: String
  @Binding private var text: String
  @Binding private var isInvalid: Bool
  
  @State private var isPasswordVisible: Bool = false
  @FocusState private var isFocused: Bool
  
  @State private var alignment: Alignment = .leading
  @State private var placeholderStyle: PlaceholderStyle = .default
  @State private var borderStyle: BorderStyle = .default
  
  private var isEditing: Bool {
    isFocused || !text.isEmpty
  }
  
  // MARK: - Initialization
  
  public init(_ type: TextFieldType = .standard,
              placeholder: String,
              text: Binding<String>,
              isInvalid: Binding<Bool>) {
    self.type = type
    self.placeholder = placeholder
    self._text = text
    self._isInvalid = isInvalid
  }
  
  // MARK: - Body
  
  public var body: some View {
    ZStack(alignment: .leading) {
      contentView
      placeholderLabel
    }
    .frame(height: Constants.containerHeight)
    .onTapGesture {
      isFocused = true
    }
    .onChange(of: [isEditing, isInvalid]) {
      withAnimation(.easeOut(duration: 0.15)) {
        updateStyles()
      }
    }
    .onChange(of: text) {
      isInvalid = false
    }
  }
  
  // MARK: - View Components
  
  private var contentView: some View {
    Group {
      switch type {
      case .standard:
        standardTextField
      case .secure:
        secureTextField
      }
    }
    .padding(.vertical, Constants.verticalPadding)
    .padding(.horizontal, Constants.horizontalPadding)
    .background(
      RoundedRectangle(cornerRadius: Constants.cornerRadius)
        .strokeBorder(borderStyle.color,
                      style: StrokeStyle(lineWidth: borderStyle.width))
    )
  }
  
  private var standardTextField: some View {
    TextField("", text: $text)
      .focused($isFocused)
      .autocorrectionDisabled(true)
      .textInputAutocapitalization(.never)
      .frame(height: Constants.textFieldHeight)
  }
  
  private var secureTextField: some View {
    HStack {
      ZStack {
        TextField("", text: $text)
          .opacity(isPasswordVisible ? 1 : 0)
        
        SecureField("", text: $text)
          .opacity(isPasswordVisible ? 0 : 1)
      }
      .focused($isFocused)
      .autocorrectionDisabled(true)
      .textInputAutocapitalization(.never)
      .frame(height: Constants.textFieldHeight)
      
      Button(action: { isPasswordVisible.toggle() }) {
        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
          .foregroundColor(Constants.eyeIconColor)
      }
    }
  }
  
  private var placeholderLabel: some View {
    Text(placeholder)
      .font(.custom("Roboto-Regular", size: placeholderStyle.fontSize))
      .foregroundStyle(placeholderStyle.textColor)
      .padding(.horizontal, 5)
      .background(
        Color.white
          .opacity(placeholderStyle.backgroundOpacity)
      )
      .padding(.horizontal, 13)
      .offset(y: placeholderStyle.offset)
  }
  
  // MARK: - Private Methods
  
  private func updateStyles() {
    if isInvalid {
      applyInvalidStyles()
    } else if isEditing {
      applyActiveStyles()
    } else {
      applyDefaultStyles()
    }
  }
  
  private func applyActiveStyles() {
    borderStyle = .active
    placeholderStyle = .active
  }
  
  private func applyInvalidStyles() {
    borderStyle = .invalid(from: borderStyle)
    placeholderStyle = .invalid(from: placeholderStyle)
  }
  
  private func applyDefaultStyles() {
    borderStyle = .default
    placeholderStyle = .default
  }
}

// MARK: - Helper Structs

extension MaterialDesignTextField {
  
  private struct BorderStyle {
    let width: CGFloat
    let color: Color
    
    static let `default` = BorderStyle(
      width: Constants.defaultBorderWidth,
      color: Constants.defaultColor
    )
    
    static let active = BorderStyle(
      width: Constants.activeBorderWidth,
      color: Constants.activeColor
    )
    
    static func invalid(from: BorderStyle) -> BorderStyle {
      BorderStyle(
        width: from.width,
        color: Constants.errorColor
      )
    }
  }
  
  private struct PlaceholderStyle: Equatable {
    let fontSize: CGFloat
    let textColor: Color
    let backgroundOpacity: Double
    let offset: CGFloat
    
    static let `default` = PlaceholderStyle(
      fontSize: Constants.defaultFontSize,
      textColor: Constants.defaultColor,
      backgroundOpacity: 0,
      offset: 0
    )
    
    static let active = PlaceholderStyle(
      fontSize: Constants.activeFontSize,
      textColor: Constants.activeColor,
      backgroundOpacity: 1,
      offset: Constants.activeOffset
    )
    
    static func invalid(from: PlaceholderStyle) -> PlaceholderStyle {
      PlaceholderStyle(
        fontSize: from.fontSize,
        textColor: from == .default ? from.textColor : Constants.errorColor,
        backgroundOpacity: from.backgroundOpacity,
        offset: from.offset
      )
    }
  }
}
