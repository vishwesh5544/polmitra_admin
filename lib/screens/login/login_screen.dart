import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polmitra_admin/bloc/auth/auth_bloc.dart';
import 'package:polmitra_admin/bloc/auth/auth_event.dart';
import 'package:polmitra_admin/bloc/auth/auth_state.dart';
import 'package:polmitra_admin/screens/home_screen/home_screen.dart';
import 'package:polmitra_admin/services/prefs_services.dart';
import 'package:polmitra_admin/utils/border_provider.dart';
import 'package:polmitra_admin/utils/color_provider.dart';
import 'package:polmitra_admin/utils/text_builder.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final double _formLabelFontSize = 16.0;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthSuccess) {
          await PrefsService.setUserId(state.user.uid);
          await PrefsService.setLoginStatus(true);
          await PrefsService.setRole(state.user.role);
          await PrefsService.saveUser(state.user);
          _navigateToHomeScreen();
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FlutterLogo(size: 100),
                  const SizedBox(height: 40),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextBuilder.getTextStyle(fontSize: _formLabelFontSize),
                      border: BorderProvider.createBorder(),
                      enabledBorder: BorderProvider.createBorder(),
                      focusedBorder: BorderProvider.createBorder(),
                    ),
                    validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextBuilder.getTextStyle(fontSize: _formLabelFontSize),
                      border: BorderProvider.createBorder(),
                      enabledBorder: BorderProvider.createBorder(),
                      focusedBorder: BorderProvider.createBorder(),
                    ),
                    obscureText: true,
                    validator: (value) => value!.isEmpty ? 'Please enter your password' : null,
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(10),
                      fixedSize: const Size(150, 45),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      backgroundColor: ColorProvider.vibrantSaffron,
                    ),
                    child: TextBuilder.getText(
                        text: "Login", color: ColorProvider.normalWhite, fontSize: 18, fontWeight: FontWeight.bold),
                    onPressed: () async {
                      // if (_formKey.currentState!.validate()) {
                      //   _formKey.currentState!.save();
                      //   // Perform login action
                      //   print('Email: $_email, Password: $_password');
                      // }
                      final bloc = context.read<AuthBloc>();
                      await PrefsService.clear();
                      bloc.add(LoginRequested(email: _emailController.text, password: _passwordController.text));
                      // _navigateToHomeScreen();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToHomeScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }
}
