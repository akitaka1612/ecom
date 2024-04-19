import 'package:bee2bee/constants/route_animation.dart';
import 'package:bee2bee/main.dart';
import 'package:bee2bee/models/user_model.dart';
import 'package:bee2bee/screens/home.dart';
import 'package:bee2bee/screens/otp.dart';
import 'package:bee2bee/screens/profile.dart';
import 'package:bee2bee/services/api_service.dart';
import 'package:bee2bee/services/user_data_storage_service.dart';
import 'package:bee2bee/widgets/basic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:proste_bezier_curve/proste_bezier_curve.dart';

class LoginScreen extends StatefulWidget {
  final bool isEditing;
  const LoginScreen({Key? key, required this.isEditing}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController _textController = TextEditingController();

  bool _phoneNumberValidator(String value) {
    String pattern = r'^[6-9]*[0-9]{9}$';
    RegExp regex = RegExp(pattern.toString());
    return regex.hasMatch(pattern);
  }

  bool emailValidator(String email) {
    String regexp =
        r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?";
    RegExp reg = RegExp(regexp);
    return reg.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      // backgroundColor: Colors.white,
      body: Container(
        child: Stack(
          // alignment: Alignment.topLeft,
          children: [
            /// Wavy line
            ClipPath(
              clipper: ProsteBezierCurve(
                position: ClipPosition.bottom,
                list: [
                  BezierCurveSection(
                    start: Offset(0, 175),
                    top: Offset(size.width / 4, 150),
                    end: Offset(size.width / 2, 175),
                  ),
                  BezierCurveSection(
                    start: Offset(size.width / 2, 175),
                    top: Offset(size.width / 4 * 3, 200),
                    end: Offset(size.width, 175),
                  ),
                ],
              ),
              child: Container(
                height: 200,
                color: Color(0xffFFF0C9),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Spacer(),
                      Image.asset(
                        "assets/images/logo.png",
                        height: 100,
                        alignment: Alignment.topCenter,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "BEE\n2\nBEE",
                        style: Theme.of(context).textTheme.headline1!.copyWith(color: Colors.black),
                      ),
                      Spacer()
                    ],
                  ),
                  SizedBox(height: 50),
                  Text(
                    "Welcome back!",
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Email/Phone",
                    style: Theme.of(context).textTheme.headline3,
                  ),
                  Form(
                    key: formKey,
                    child: TextFormField(
                      controller: _textController,
                      validator: (String? val) => val!.isEmpty
                          ? "field can't be empty"
                          : (!emailValidator(val) &&
                                  !_phoneNumberValidator(val))
                              ? "enter correct email id/phone no"
                              : null,
                      decoration: InputDecoration(
                        hintText: "Enter Email Id / Phone No",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            if (isLoading) loadingAnimation()
          ],
        ),
      ),
      bottomNavigationBar: nextButton("Get OTP", () async {
        if (formKey.currentState!.validate()) {
          bool isPhone = RegExp(r'^[0-9]+$').hasMatch(_textController.text);
          print("is phone $isPhone");
          setState(() {
            isLoading = true;
          });
          bool? isPresent = await ApiService().checkUser(_textController.text);
          setState(() {
            isLoading = false;
          });

          if (isPresent != null) {
            bool isVarified = await Navigator.push(
              context,
              SlideLeftRoute(
                widget: OtpScreen(
                    primary: _textController.text,
                    isPresent: isPresent,
                    isPhone: isPhone),
              ),
            );

            if (isVarified) {
              if (isPresent) {
                print(isPresent);
                await ApiService().login({"loginType": isPhone? "phone": "email", "loginWith": _textController.text});
                Navigator.pushReplacement(
                    context, SlideLeftRoute(widget: HomeScreen()));
              } else {
                print("else part");
                if (widget.isEditing) {
                  Navigator.pop(context, _textController.text);
                } else {
                  await Navigator.push(
                    context,
                    SlideLeftRoute(
                      widget: ProfileScreen(
                        isFirstTime: true,
                        userModel: UserModel(
                          cartItems: [],
                          deliveryAddress: [],
                          deviceToken: "deviceToken",
                          dob: DateTime.now(),
                          emailId: isPhone ? "" : _textController.text,
                          shopName: "",
                          orders: [],
                          phoneNo: isPhone ? _textController.text : "",
                          profilePic: "",
                          userType: "customer",
                          proprietorName: "",
                          gst: "",
                        ),
                      ),
                    ),
                  );
                  
                  Navigator.pushReplacement(
                      context, SlideLeftRoute(widget: HomeScreen()));
                }
              }
            }
          }
        }
      }),
    );
  }
}
