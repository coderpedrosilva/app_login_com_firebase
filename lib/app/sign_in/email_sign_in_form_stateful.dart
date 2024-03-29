import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_login/app/sign_in/email_sign_in_model.dart';
import 'package:firebase_login/app/sign_in/validators.dart';
import 'package:firebase_login/common_widgets/form_submit_button.dart';
import 'package:firebase_login/common_widgets/show_exception_alert_dialog.dart';
import 'package:firebase_login/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmailSignInFormStateful extends StatefulWidget
    with EmailAndPasswordValidators {
  @override
  _EmailSignInFormStatefulState createState() =>
      _EmailSignInFormStatefulState();
}

class _EmailSignInFormStatefulState extends State<EmailSignInFormStateful> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  String get _email => _emailController.text;
  String get _password => _passwordController.text;
  EmailSignInFormType _formType = EmailSignInFormType.signIn;
  bool _submitted = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() {
      _submitted = true;
      _isLoading = true;
    });
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      if (_formType == EmailSignInFormType.signIn) {
        await auth.signInWithEmailAndPassword(_email, _password);
      } else {
        await auth.createUserWithEmailandPassword(_email, _password);
      }
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      showExceptionAlertDialog(
        context,
        title: 'Login Falhou',
        exception: e,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _emailEditingComplete() {
    final newFocus = widget.emailValidator.isValid(_email)
        ? _passwordFocusNode
        : _emailFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _toggleFormType() {
    setState(() {
      _submitted = false;
      _formType = _formType == EmailSignInFormType.signIn
          ? EmailSignInFormType.register
          : EmailSignInFormType.signIn;
    });
    _emailController.clear();
    _passwordController.clear();
  }

  List<Widget> _buildChildren() {
    final primaryText =
        _formType == EmailSignInFormType.signIn ? 'Entrar' : 'Criar uma conta';
    final secondaryText = _formType == EmailSignInFormType.signIn
        ? 'Precisa de uma conta? Registre-se'
        : 'Já tem uma conta? Entrar';

    bool submitEnabled = widget.emailValidator.isValid(_email) &&
        widget.passwordValidator.isValid(_password) &&
        !_isLoading;

    bool showErrorTextEmail =
        _submitted && !widget.emailValidator.isValid(_email);
    bool showErrorTextPassword =
        _submitted && !widget.passwordValidator.isValid(_password);

    return [
      TextField(
        controller: _emailController,
        focusNode: _emailFocusNode,
        decoration: InputDecoration(
          labelText: 'Email',
          hintText: 'teste@teste.com',
          errorText: showErrorTextEmail ? widget.invalidEmailErrorText : null,
          enabled: _isLoading == false,
        ),
        autocorrect: false,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        onChanged: (email) => _updateState(),
        onEditingComplete: _emailEditingComplete,
      ),
      SizedBox(height: 8.0),
      TextField(
        controller: _passwordController,
        focusNode: _passwordFocusNode,
        decoration: InputDecoration(
          labelText: 'Senha',
          errorText:
              showErrorTextPassword ? widget.invalidPasswordErrorText : null,
          enabled: _isLoading == false,
        ),
        obscureText: true,
        textInputAction: TextInputAction.done,
        onChanged: (password) => _updateState(),
        onEditingComplete: _submit,
      ),
      SizedBox(height: 8.0),
      FormSubmitButton(
        text: primaryText,
        onPressed: submitEnabled ? _submit : null,
      ),
      SizedBox(height: 8.0),
      FlatButton(
        child: Text(secondaryText),
        onPressed: !_isLoading ? _toggleFormType : null,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: _buildChildren(),
      ),
    );
  }

  void _updateState() {
    setState(() {});
  }
}
