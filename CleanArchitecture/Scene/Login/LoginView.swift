//
//  LoginView.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 7/29/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import SwiftUI
import Combine
import Factory

struct LoginView: View {
    final class Triggers: ObservableObject {
        var login = PassthroughSubject<Void, Never>()
    }
    
    @StateObject var viewModel: LoginViewModel
    @StateObject var input: LoginViewModel.Input
    @StateObject var output: LoginViewModel.Output
    @StateObject var cancelBag: CancelBag
    @StateObject var triggers: Triggers
    
    var body: some View {
        LoadingView(isShowing: $output.isLoading, text: .constant("")) {
            VStack(alignment: .leading) {
                Text("User name:")
                TextField("", text: self.$input.username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .accessibilityIdentifier("userTextField")
                Text(self.output.usernameValidationMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                Text("Password:")
                    .padding(.top)
                SecureField("", text: self.$input.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .accessibilityIdentifier("passwordTextField")
                Text(self.output.passwordValidationMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                HStack {
                    Spacer()
                    Button("Login") {
                        self.triggers.login.send(())
                    }
                    .disabled(!self.output.isLoginEnabled)
                    .padding(.top)
                    .accessibilityIdentifier("loginButton")
                    Spacer()
                }
                Spacer()
            }
            .padding()
        }
        .alert(isPresented: $output.alert.isShowing) {
            Alert(
                title: Text(output.alert.title),
                message: Text(output.alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    init(viewModel: LoginViewModel) {
        let cancelBag = CancelBag()
        let triggers = Triggers()
        let input = LoginViewModel.Input(loginTrigger: triggers.login.eraseToAnyPublisher())
        let output = viewModel.transform(input, cancelBag: cancelBag)
        
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._input = StateObject(wrappedValue: input)
        self._output = StateObject(wrappedValue: output)
        self._cancelBag = StateObject(wrappedValue: cancelBag)
        self._triggers = StateObject(wrappedValue: triggers)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: LoginViewModel(authGateway: Container.shared.previewAuthGateway()))
    }
}

extension Container {
    func loginView(navigationController: UINavigationController) -> Factory<LoginView> {
        Factory(self) {
            LoginView(viewModel: LoginViewModel(authGateway: self.authGateway()))
        }
    }
}
